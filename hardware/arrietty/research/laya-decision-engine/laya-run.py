#!/usr/bin/env python
"""Generic runner for a Laya checkpoint over a questions file and a data file.

It knows nothing about any dataset. Per-case answers go to --out; the
terminal gets the summary table only.
"""
import argparse
import json
import math
import os
import resource
import subprocess
import sys
import threading
import time

import numpy as np
import torch

CHECKPOINTS = {
    "english": ("convaiinnovations/laya", None),
    "multilingual": ("convaiinnovations/laya", "multilingual"),
    "typed-decisions": ("convaiinnovations/laya", "typed-decisions"),
}


GPU_FIELDS = ["memory.used", "memory.total", "utilization.gpu", "utilization.memory",
              "power.draw", "temperature.gpu", "clocks.current.graphics"]


class GpuSampler(threading.Thread):
    """One reading of the card per second, kept whole, not only its peak."""

    def __init__(self, interval=1.0):
        super().__init__(daemon=True)
        self.interval = interval
        self.samples = []
        self.phase = "load"
        self.stop_flag = threading.Event()

    def run(self):
        while not self.stop_flag.is_set():
            try:
                out = subprocess.run(
                    ["nvidia-smi", "--query-gpu=" + ",".join(GPU_FIELDS),
                     "--format=csv,noheader,nounits"],
                    capture_output=True, text=True, timeout=10)
                v = [x.strip() for x in out.stdout.strip().splitlines()[0].split(",")]
                self.samples.append({"t": round(time.time(), 3), "phase": self.phase,
                                     "mem_used_mb": int(float(v[0])),
                                     "mem_total_mb": int(float(v[1])),
                                     "util_gpu_pct": int(float(v[2])),
                                     "util_mem_pct": int(float(v[3])),
                                     "power_w": float(v[4]),
                                     "temp_c": int(float(v[5])),
                                     "clock_mhz": int(float(v[6]))})
            except Exception:
                pass
            self.stop_flag.wait(self.interval)

    @property
    def peak_mb(self):
        return max([s["mem_used_mb"] for s in self.samples], default=0)

    def stats(self, phase=None):
        rows = [s for s in self.samples if phase is None or s["phase"] == phase]
        if not rows:
            return {}
        out = {"samples": len(rows)}
        for key in ("mem_used_mb", "util_gpu_pct", "util_mem_pct", "power_w",
                    "temp_c", "clock_mhz"):
            v = sorted(float(s[key]) for s in rows)
            out[key] = {"min": v[0], "p50": v[len(v) // 2],
                        "p95": v[min(len(v) - 1, int(0.95 * len(v)))],
                        "max": v[-1], "mean": round(sum(v) / len(v), 2)}
        return out

    def write_csv(self, path):
        os.makedirs(os.path.dirname(os.path.abspath(path)) or ".", exist_ok=True)
        cols = ["t", "phase", "mem_used_mb", "mem_total_mb", "util_gpu_pct",
                "util_mem_pct", "power_w", "temp_c", "clock_mhz"]
        with open(path, "w") as f:
            f.write(",".join(cols) + "\n")
            for s in self.samples:
                f.write(",".join(str(s[c]) for c in cols) + "\n")

    def stop(self):
        self.stop_flag.set()
        self.join(timeout=5)
        return self.peak_mb


def load_questions(path):
    with open(path) as f:
        raw = json.load(f)
    if isinstance(raw, list):
        out = {}
        for q in raw:
            qid = q["id"]
            out[qid] = {k: v for k, v in q.items() if k != "id"}
        return out
    return raw


def load_cases(path):
    cases = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line:
                cases.append(json.loads(line))
    return cases


def case_labels(case, qids):
    labels = case.get("labels")
    if labels is None and "label" in case and len(qids) == 1:
        labels = {qids[0]: case["label"]}
    return labels or {}


def build_agent(checkpoint, device):
    from laya.agent import Agent
    if checkpoint in CHECKPOINTS:
        repo, sub = CHECKPOINTS[checkpoint]
    else:
        repo, sub = checkpoint, None
    return Agent(repo, device=device, subfolder=sub)


def prepare_items(agent, questions, qids, state):
    """Items for one state, and whether the state was cut to fit the context."""
    from laya.common import QTYPES, build_sequence, render_options, serialize_state
    max_len = agent.cfg.get("max_len", 512)
    head_max_len = agent.cfg.get("head_max_len", 192)
    items, over = [], False
    state_len = len(agent.tok(serialize_state(state), add_special_tokens=False)["input_ids"])
    for qid in qids:
        q = agent._to_internal(questions[qid])
        seq, markers = build_sequence(agent.tok, state, q, max_len, head_max_len)
        if len(markers) != len(render_options(q)):
            raise ValueError("question %r options exceed head_max_len=%d" % (qid, head_max_len))
        empty, _ = build_sequence(agent.tok, "", q, max_len, head_max_len)
        if state_len > max_len - (len(empty) - 1):
            over = True
        items.append({"ids": seq, "markers": markers, "qtype": QTYPES[q["t"]]})
    return items, over


@torch.no_grad()
def forward_logits(agent, items):
    """Raw per-option logits for a flat list of items, one forward pass."""
    from laya.common import collate_items
    b = collate_items([items], agent.tok.pad_token_id)
    use_amp = agent.device.type == "cuda"
    with torch.autocast(device_type=agent.device.type, dtype=agent.dtype, enabled=use_amp):
        logits, _act = agent.model(
            b["input_ids"].to(agent.device),
            b["attention_mask"].to(agent.device),
            b["marker_pos"].to(agent.device),
            b["marker_mask"].to(agent.device),
            b["qtype"].to(agent.device),
        )
    return logits.float().cpu().numpy(), int(b["attention_mask"].sum())


def softmax(z):
    z = z - z.max()
    p = np.exp(z)
    return p / p.sum()


def shipped_temperature(agent, qtype, k):
    from laya.common import temp_bucket
    return float(agent.temperature_by_options.get(temp_bucket(qtype, k), agent.temperature[qtype]))


def option_keys(questions, qid):
    q = questions[qid]
    t = q["type"]
    if t == "choice":
        crit = q.get("criteria")
        return list(crit.keys()) if isinstance(crit, dict) else list(crit)
    if t == "score":
        return [str(i) for i in range(len(q.get("criteria") or []))]
    return ["false", "true"]


def label_index(questions, qid, label):
    keys = option_keys(questions, qid)
    t = questions[qid]["type"]
    if t == "noul":
        if isinstance(label, bool):
            return 1 if label else 0
        if isinstance(label, (int, float)):
            return int(label)
        return 1 if str(label).lower() in ("true", "yes", "1") else 0
    if isinstance(label, int) and not isinstance(label, bool):
        return label if 0 <= label < len(keys) else None
    label = str(label)
    return keys.index(label) if label in keys else None


def fit_temperature(rows):
    """One scalar on top of the raw logits, by NLL over labelled rows."""
    labelled = [r for r in rows if r["label_index"] is not None]
    if not labelled:
        return None
    best_t, best_nll = 1.0, float("inf")
    for t in np.exp(np.linspace(math.log(0.05), math.log(20.0), 240)):
        nll = 0.0
        for r in labelled:
            p = softmax(np.asarray(r["logits"]) / float(t))
            nll -= math.log(max(1e-12, p[r["label_index"]]))
        if nll < best_nll:
            best_nll, best_t = nll, float(t)
    return best_t


def metrics(rows, bins=15):
    from laya.common import ece_score
    scored = [r for r in rows if r["label_index"] is not None]
    if not scored:
        return {"cases": len(rows), "labelled": 0}
    correct = np.array([1.0 if r["pred_index"] == r["label_index"] else 0.0 for r in scored])
    conf = np.array([float(r["probs"][r["pred_index"]]) for r in scored])
    brier = []
    for r in scored:
        p = np.asarray(r["probs"], dtype=float)
        y = np.zeros_like(p)
        y[r["label_index"]] = 1.0
        brier.append(float(((p - y) ** 2).sum()))
    return {
        "cases": len(rows),
        "labelled": len(scored),
        "accuracy": float(correct.mean()),
        "brier": float(np.mean(brier)),
        "ece": ece_score(conf, correct, bins=bins),
    }


def peak_rss_mb():
    return resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024.0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--questions", required=True)
    ap.add_argument("--data", required=True)
    ap.add_argument("--checkpoint", default="english")
    ap.add_argument("--device", default="cuda", choices=["cuda", "cpu"])
    ap.add_argument("--batch", type=int, default=1, help="cases per forward pass")
    ap.add_argument("--out", required=True)
    ap.add_argument("--fit-temperature", action="store_true",
                    help="fit one scalar on the first half, report on the second half")
    ap.add_argument("--limit", type=int, default=0)
    ap.add_argument("--skip-over-context", action="store_true",
                    help="leave out a case whose state does not fit the checkpoint context")
    ap.add_argument("--warmup", type=int, default=3)
    ap.add_argument("--json-summary", default="")
    ap.add_argument("--gpu-log", default="",
                    help="write every GPU reading of this run to this CSV")
    args = ap.parse_args()

    questions = load_questions(args.questions)
    cases = load_cases(args.data)
    # A case may carry its own questions, for a set whose options change per case.
    case_questions = [c.get("questions") or questions for c in cases]
    qids = list(questions.keys())
    if args.limit:
        cases = cases[:args.limit]

    sampler = GpuSampler()
    sampler.start()

    t0 = time.perf_counter()
    agent = build_agent(args.checkpoint, args.device)
    load_s = time.perf_counter() - t0
    if str(agent.device) != args.device and not str(agent.device).startswith(args.device):
        print("ERROR: asked for %s, the agent sits on %s" % (args.device, agent.device), file=sys.stderr)
        sys.exit(2)

    if args.device == "cuda":
        torch.cuda.reset_peak_memory_stats()
    sampler.phase = "prepare"

    case_qids = [list(q.keys()) for q in case_questions]
    prepared_all = [prepare_items(agent, case_questions[i], case_qids[i], c["state"])
                    for i, c in enumerate(cases)]
    over_context = [i for i, (_, over) in enumerate(prepared_all) if over]
    if args.skip_over_context and over_context:
        keep = [i for i in range(len(cases)) if i not in set(over_context)]
        cases = [cases[i] for i in keep]
        case_questions = [case_questions[i] for i in keep]
        case_qids = [case_qids[i] for i in keep]
        prepared_all = [prepared_all[i] for i in keep]
    prepared = [it for it, _ in prepared_all]

    sampler.phase = "warmup"
    for _ in range(min(args.warmup, len(prepared))):
        forward_logits(agent, prepared[0])
    if args.device == "cuda":
        torch.cuda.synchronize()
    sampler.phase = "measure"

    rows, latencies, tokens_total = [], [], 0
    for start in range(0, len(cases), args.batch):
        group = list(range(start, min(start + args.batch, len(cases))))
        flat = [it for i in group for it in prepared[i]]
        t = time.perf_counter()
        logits, ntok = forward_logits(agent, flat)
        if args.device == "cuda":
            torch.cuda.synchronize()
        latencies.append((time.perf_counter() - t) * 1000.0)
        tokens_total += ntok
        r = 0
        for i in group:
            labels = case_labels(cases[i], case_qids[i])
            for j, qid in enumerate(case_qids[i]):
                k = len(prepared[i][j]["markers"])
                qt = prepared[i][j]["qtype"]
                rows.append({
                    "case": i,
                    "question": qid,
                    "type": case_questions[i][qid]["type"],
                    "logits": [float(v) for v in logits[r, :k]],
                    "shipped_t": shipped_temperature(agent, qt, k),
                    "options": option_keys(case_questions[i], qid),
                    "label": labels.get(qid),
                    "label_index": (label_index(case_questions[i], qid, labels[qid])
                                    if qid in labels else None),
                })
                r += 1

    gpu_peak = sampler.stop()
    gpu_stats = {"whole_run": sampler.stats(),
                 "measure_only": sampler.stats("measure"),
                 "load_only": sampler.stats("load")}
    if args.gpu_log:
        sampler.write_csv(args.gpu_log)
    if args.device == "cuda":
        torch_peak = torch.cuda.max_memory_allocated() / (1024 ** 2)
        torch_mem = {
            "peak_allocated_mb": round(torch_peak, 1),
            "peak_reserved_mb": round(torch.cuda.max_memory_reserved() / (1024 ** 2), 1),
            "allocated_at_end_mb": round(torch.cuda.memory_allocated() / (1024 ** 2), 1),
            "reserved_at_end_mb": round(torch.cuda.memory_reserved() / (1024 ** 2), 1),
        }
    else:
        torch_peak, torch_mem = 0.0, {}

    half = len(cases) // 2
    if args.fit_temperature:
        report_rows = [r for r in rows if r["case"] >= half]
        # One scalar per question id, so a mixed file does not average two scales.
        t_fit = {}
        for qid in sorted(set(r["question"] for r in rows)):
            fit_rows = [r for r in rows if r["case"] < half and r["question"] == qid]
            t_fit[qid] = fit_temperature(fit_rows) or 1.0
        scale = t_fit
    else:
        report_rows = rows
        t_fit = None
        scale = None

    for r in rows:
        t = scale[r["question"]] if scale else r["shipped_t"]
        r["temperature"] = float(t)
        r["probs"] = [float(v) for v in softmax(np.asarray(r["logits"]) / max(1e-3, float(t)))]
        r["pred_index"] = int(np.argmax(r["probs"]))
        r["prediction"] = r["options"][r["pred_index"]]

    os.makedirs(os.path.dirname(os.path.abspath(args.out)) or ".", exist_ok=True)
    with open(args.out, "w") as f:
        for r in rows:
            f.write(json.dumps({k: v for k, v in r.items() if k != "logits"} |
                               {"logits": r["logits"]}) + "\n")

    lat = np.array(latencies) if latencies else np.array([0.0])
    per_q = {}
    for qid in qids:
        per_q[qid] = metrics([r for r in report_rows if r["question"] == qid])
    overall = metrics(report_rows)

    summary = {
        "checkpoint": args.checkpoint,
        "device": str(agent.device),
        "dtype": str(agent.dtype),
        "max_len": agent.cfg.get("max_len"),
        "cases": len(cases),
        "reported_cases": len(set(r["case"] for r in report_rows)),
        "questions_per_case": len(qids),
        "per_case_questions": any(c.get("questions") for c in cases),
        "over_context": len(over_context),
        "skipped_over_context": len(over_context) if args.skip_over_context else 0,
        "batch": args.batch,
        "cold_load_s": round(load_s, 3),
        "calls": len(latencies),
        "p50_ms": float(np.percentile(lat, 50)),
        "p95_ms": float(np.percentile(lat, 95)),
        "questions_per_s": float(len(rows) / (lat.sum() / 1000.0)) if lat.sum() else 0.0,
        "peak_gpu_mb_nvidia_smi": gpu_peak,
        "peak_gpu_mb_torch": round(torch_peak, 1),
        "torch_memory": torch_mem,
        "gpu": gpu_stats,
        "peak_rss_mb": round(peak_rss_mb(), 1),
        "input_tokens": tokens_total,
        "fitted_temperature": t_fit,
        "overall": overall,
        "per_question": per_q,
    }
    if args.json_summary:
        os.makedirs(os.path.dirname(os.path.abspath(args.json_summary)) or ".", exist_ok=True)
        with open(args.json_summary, "w") as f:
            json.dump(summary, f, indent=2)

    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
