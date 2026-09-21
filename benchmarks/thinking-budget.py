#!/usr/bin/env python3
"""thinking-budget.py — the forced answers of an EvalPlus run under a thinking budget.

A server that takes a thinking budget (`llama-server --reasoning-budget N
--reasoning-budget-message MSG`) closes the thinking at N tokens and the
model answers with what it has. Fast mode is N = 8192 with max_tokens 16384
(`docs/methodology/evalplus.md`). This tool covers the steps around such a
run:

  count    <run-dir> --message MSG
      The forced count from the finish log and the empty count from the
      samples, the two numbers a run reports beside its score.

  splice   <run-dir> <fast-dir> --message MSG [--think 8192]
      Reuse an earlier run of the same config at a thinking budget of
      --think or more: copy its samples and finish lines for every problem
      whose reasoning stayed inside --think and was not forced, so
      `run-humaneval.sh` in <fast-dir> generates only the rest under the
      fast flags. Temperature 0 makes the kept answers the same text the
      fast run would produce.

  prepare  <run-dir> <rerun-dir> --message MSG
      The optional proof run: list the problems where the budget message
      fired and the answer failed, copy the run's samples into <rerun-dir>
      without those problems, so `run-humaneval.sh` regenerates only them,
      at a generous budget and without the flag.

  report   <run-dir> <rerun-dir> --message MSG
      After the proof run: one line per forced problem with its cell.

      forced-pass       the budget fired and the answer still passed
      forced-fail-late  the answer failed under the budget and passed
                        without it at N tokens: the budget was too small
      forced-fail-loop  the answer failed under the budget and hit the
                        generous budget without it: non-convergence
      forced-fail-wrong the answer failed both ways: the model's own limit

Reasoning tokens come from usage.completion_tokens_details when the server
reports them, else from completion_tokens split by the character ratio of
reasoning to answer.
"""
import argparse
import glob
import json
import os
import shutil
import sys

def reasoning_tokens(row):
    if row.get("reasoning_tokens"):
        return int(row["reasoning_tokens"])
    total = row.get("completion_tokens") or 0
    r = row.get("reasoning_len") or 0
    c = row.get("content_len") or 0
    if r + c == 0:
        return 0
    return int(round(total * r / (r + c)))


def answer_tokens(row):
    return (row.get("completion_tokens") or 0) - reasoning_tokens(row)


def load_finish(run_dir):
    path = os.path.join(run_dir, "finish.jsonl")
    last = {}
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            row = json.loads(line)
            if row.get("task_id"):
                last[row["task_id"]] = row
    return last


def load_eval(run_dir):
    files = glob.glob(os.path.join(run_dir, "humaneval", "*_eval_results.json"))
    if not files:
        sys.exit(f"no eval results under {run_dir}/humaneval")
    ev = json.load(open(files[0]))["eval"]
    return {t: (v[0].get("base_status") == "pass" and v[0].get("plus_status", "pass") == "pass") for t, v in ev.items()}


def forced_failed(run_dir, message):
    finish = load_finish(run_dir)
    passed = load_eval(run_dir)
    forced = {t for t, r in finish.items() if message in (r.get("reasoning_tail") or "")}
    return finish, passed, forced, sorted(t for t in forced if not passed.get(t, False))


def samples_path(run_dir):
    files = [p for p in glob.glob(os.path.join(run_dir, "humaneval", "*.jsonl")) if not p.endswith(".raw.jsonl")]
    if not files:
        sys.exit(f"no samples under {run_dir}/humaneval")
    return files[0]


def count(args):
    finish = load_finish(args.run_dir)
    forced = sorted((t for t, r in finish.items() if args.message in (r.get("reasoning_tail") or "")), key=lambda x: int(x.split("/")[1]))
    empty = []
    with open(samples_path(args.run_dir)) as f:
        for line in f:
            if line.strip():
                row = json.loads(line)
                if not (row.get("solution") or row.get("completion") or "").strip():
                    empty.append(row["task_id"])
    print(f"answers\t{len(finish)}\tforced\t{len(forced)}\tempty\t{len(empty)}")
    print("forced_ids\t" + " ".join(forced))
    print("empty_ids\t" + " ".join(empty))


def splice(args):
    finish = load_finish(args.run_dir)
    keep = {t for t, r in finish.items()
            if args.message not in (r.get("reasoning_tail") or "")
            and r.get("finish_reason") == "stop"
            and reasoning_tokens(r) <= args.think}
    src = os.path.join(args.run_dir, "humaneval")
    dst = os.path.join(args.fast_dir, "humaneval")
    os.makedirs(dst, exist_ok=True)
    for path in glob.glob(os.path.join(src, "*.jsonl")):
        with open(path) as f, open(os.path.join(dst, os.path.basename(path)), "w") as out:
            for line in f:
                if line.strip() and json.loads(line)["task_id"] in keep:
                    out.write(line)
    with open(os.path.join(args.fast_dir, "finish.jsonl"), "w") as out:
        for t in keep:
            out.write(json.dumps({**finish[t], "source": args.run_dir}) + "\n")
    regenerate = sorted((t for t in finish if t not in keep), key=lambda x: int(x.split("/")[1]))
    json.dump({"message": args.message, "think": args.think, "source": args.run_dir,
               "kept": sorted(keep), "regenerate": regenerate},
              open(os.path.join(args.fast_dir, "splice.json"), "w"), indent=2)
    print(f"kept\t{len(keep)}\tregenerate\t{len(regenerate)}")
    for t in regenerate:
        print(t)


def prepare(args):
    finish, passed, forced, failed = forced_failed(args.run_dir, args.message)
    src = os.path.join(args.run_dir, "humaneval")
    dst = os.path.join(args.rerun_dir, "humaneval")
    os.makedirs(dst, exist_ok=True)
    for path in glob.glob(os.path.join(src, "*.jsonl")):
        with open(path) as f, open(os.path.join(dst, os.path.basename(path)), "w") as out:
            for line in f:
                if line.strip() and json.loads(line)["task_id"] not in failed:
                    out.write(line)
    json.dump({"message": args.message, "forced": sorted(forced), "forced_failed": failed},
              open(os.path.join(args.rerun_dir, "forced.json"), "w"), indent=2)
    print(f"forced\t{len(forced)}\tforced_failed\t{len(failed)}")
    for t in failed:
        print(t)


def report(args):
    finish, passed, forced, failed = forced_failed(args.run_dir, args.message)
    natural = load_finish(args.rerun_dir)
    natural_pass = load_eval(args.rerun_dir)
    late = []
    print("task_id\tcell\tforced_tokens\tnatural_finish\tnatural_tokens\tnatural_reasoning_tokens")
    for t in sorted(forced, key=lambda x: int(x.split("/")[1])):
        fr = finish[t]
        if passed.get(t):
            print(f"{t}\tforced-pass\t{fr.get('completion_tokens')}\t\t\t")
            continue
        nr = natural.get(t)
        if not nr:
            print(f"{t}\tmissing\t{fr.get('completion_tokens')}\t\t\t")
            continue
        think = reasoning_tokens(nr)
        if nr.get("finish_reason") == "length":
            cell = "forced-fail-loop"
        elif natural_pass.get(t):
            cell = "forced-fail-late"
            late.append(think)
        else:
            cell = "forced-fail-wrong"
        print(f"{t}\t{cell}\t{fr.get('completion_tokens')}\t{nr.get('finish_reason')}\t{nr.get('completion_tokens')}\t{think}")
    cells = {"forced-pass": 0, "forced-fail-late": 0, "forced-fail-loop": 0, "forced-fail-wrong": 0}
    for t in forced:
        if passed.get(t):
            cells["forced-pass"] += 1
        elif t in natural and natural[t].get("finish_reason") == "length":
            cells["forced-fail-loop"] += 1
        elif t in natural and natural_pass.get(t):
            cells["forced-fail-late"] += 1
        elif t in natural:
            cells["forced-fail-wrong"] += 1
    print("summary\t" + "\t".join(f"{k}={v}" for k, v in cells.items()))
    if late:
        print(f"late_answers\t{len(late)}\tlongest {max(late)} reasoning tokens")
    else:
        print("late_answers\t0\tno late answer")


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    c = sub.add_parser("count")
    c.add_argument("run_dir")
    c.add_argument("--message", required=True)
    c.set_defaults(fn=count)
    sp = sub.add_parser("splice")
    sp.add_argument("run_dir")
    sp.add_argument("fast_dir")
    sp.add_argument("--message", required=True)
    sp.add_argument("--think", type=int, default=8192)
    sp.set_defaults(fn=splice)
    for name, fn in (("prepare", prepare), ("report", report)):
        s = sub.add_parser(name)
        s.add_argument("run_dir")
        s.add_argument("rerun_dir")
        s.add_argument("--message", required=True)
        s.set_defaults(fn=fn)
    args = p.parse_args()
    args.fn(args)


if __name__ == "__main__":
    main()
