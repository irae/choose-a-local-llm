import json, math, sys, time
import numpy as np
import torch
from laya.common import QTYPES, build_sequence, collate_items, render_options, temp_bucket

def to_internal(qdef):
    t = qdef["type"]
    crit = qdef.get("criteria")
    if t == "choice" and isinstance(crit, list):
        crit = {c: None for c in crit}
    ins = qdef["instructions"]
    if not isinstance(ins, str):
        ins = json.dumps(ins)
    return {"t": t, "ins": ins, "crit": crit}

@torch.no_grad()
def score_cases(agent, cases, max_tokens=16384, max_seqs=128, progress=""):
    '''cases: [(state, {qid: qdef})] -> (raw_logits per question, index, seconds, n_dropped).

    Every question of every case is one sequence. Sequences are length-sorted and packed into
    token-budgeted batches so padding stays small. Returns UNCALIBRATED logits; temperature is
    applied later so raw/calibrated variants come from one forward pass.
    '''
    max_len = agent.cfg.get("max_len", 512)
    head_max_len = agent.cfg.get("head_max_len", 192)
    items, index, dropped = [], [], 0
    for ci, (state, questions) in enumerate(cases):
        for qid, qdef in questions.items():
            q = to_internal(qdef)
            try:
                ids, markers = build_sequence(agent.tok, state, q, max_len, head_max_len)
            except Exception:
                index.append((ci, qid, QTYPES[q["t"]], 0)); items.append(None); dropped += 1
                continue
            if len(markers) != len(render_options(q)):
                index.append((ci, qid, QTYPES[q["t"]], 0)); items.append(None); dropped += 1
                continue
            items.append({"ids": ids, "markers": markers, "qtype": QTYPES[q["t"]]})
            index.append((ci, qid, QTYPES[q["t"]], len(markers)))

    valid = [i for i, it in enumerate(items) if it is not None]
    order = sorted(valid, key=lambda i: len(items[i]["ids"]))
    out = [None] * len(items)
    t0, done, i = time.time(), 0, 0
    while i < len(order):
        j, L = i, 0
        while j < len(order) and j - i < max_seqs and max(L, len(items[order[j]]["ids"])) * (j - i + 1) <= max_tokens:
            L = max(L, len(items[order[j]]["ids"])); j += 1
        j = max(j, i + 1)
        sel = [items[order[t]] for t in range(i, j)]
        b = collate_items([sel], agent.tok.pad_token_id)
        with torch.autocast("cuda", dtype=agent.dtype, enabled=True):
            logits, _ = agent.model(b["input_ids"].cuda(), b["attention_mask"].cuda(),
                                    b["marker_pos"].cuda(), b["marker_mask"].cuda(), b["qtype"].cuda())
        logits = logits.float().cpu().numpy()
        for r in range(j - i):
            out[order[i + r]] = logits[r, :len(sel[r]["markers"])]
        done += j - i
        if progress:
            el = time.time() - t0
            msg = "\r  [%s] %d/%d seq | %.0f seq/s | ETA %ds    " % (
                progress, done, len(order), done/max(el, 1e-9),
                int(el*(len(order)-done)/max(1, done)))
            sys.stdout.write(msg)
            sys.stdout.flush()
        i = j
    if progress:
        print("\r  [%s] %d sequences in %.1fs (%d dropped: options did not fit)%s" % (
            progress, len(order), time.time()-t0, dropped, " "*20))
    return out, index, time.time() - t0, dropped

def softmax_t(z, t=1.0):
    z = np.asarray(z, dtype=np.float64) / max(1e-3, float(t))
    e = np.exp(z - z.max())
    return e / e.sum()

def temp_for(agent, qt, k, calibrated=True):
    if not calibrated:
        return 1.0
    return float(agent.temperature_by_options.get(temp_bucket(qt, k), agent.temperature[qt]))

# ------------------------------------------------------------------ metrics
def ece_score(conf, correct, bins=15):
    conf, correct = np.asarray(conf, float), np.asarray(correct, float)
    if len(conf) == 0:
        return float("nan")
    edges = np.linspace(0, 1, bins + 1)
    e = 0.0
    for lo, hi in zip(edges[:-1], edges[1:]):
        sel = (conf > lo) & (conf <= hi)
        if sel.any():
            e += sel.mean() * abs(conf[sel].mean() - correct[sel].mean())
    return float(e)

def macro_f1(gold, pred):
    gold, pred = np.asarray(gold), np.asarray(pred)
    f1 = []
    for c in sorted(set(gold.tolist()) | set(pred.tolist())):
        tp = int(((pred == c) & (gold == c)).sum())
        fp = int(((pred == c) & (gold != c)).sum())
        fn = int(((pred != c) & (gold == c)).sum())
        f1.append(2*tp / max(1, 2*tp + fp + fn))
    return float(np.mean(f1))

def aurc(conf, correct):
    conf, correct = np.asarray(conf, float), np.asarray(correct, float)
    if len(conf) == 0:
        return float("nan")
    o = np.argsort(-conf)
    return float((np.cumsum(1 - correct[o]) / np.arange(1, len(o)+1)).mean())

def hard_metrics(rows):
    '''rows: [(gold_idx, probs)] -> standard single-label classification + calibration metrics.'''
    rows = [r for r in rows if r[1] is not None]
    if not rows:
        return {"n": 0}
    gold = np.array([g for g, _ in rows])
    pred = np.array([int(np.argmax(p)) for _, p in rows])
    conf = np.array([float(np.max(p)) for _, p in rows])
    corr = (pred == gold).astype(float)
    m = {"n": len(rows),
         "accuracy": float(corr.mean()),
         "macro_f1": macro_f1(gold, pred),
         "ece": ece_score(conf, corr),
         "brier": float(np.mean([((np.asarray(p) - np.eye(len(p))[g])**2).sum() for g, p in rows])),
         "nll": float(np.mean([-math.log(max(float(p[g]), 1e-12)) for g, p in rows])),
         "aurc": aurc(conf, corr),
         "mean_confidence": float(conf.mean())}
    for cov in (0.5, 0.8):
        k = max(1, int(len(conf)*cov))
        m["acc_at_%d_coverage" % int(cov*100)] = float(corr[np.argsort(-conf)[:k]].mean())
    return m

def fit_temperature(pairs, lo=0.2, hi=10.0, steps=160):
    '''pairs: [(logits, gold_idx)] -> single temperature minimising NLL (grid search, no autograd).'''
    pairs = [(np.asarray(z, float), int(g)) for z, g in pairs if z is not None]
    if len(pairs) < 25:
        return 1.0
    best_t, best = 1.0, float("inf")
    for t in np.geomspace(lo, hi, steps):
        tot = 0.0
        for z, g in pairs:
            zz = z/t
            zz = zz - zz.max()
            tot += -(zz[g] - math.log(np.exp(zz).sum()))
        if tot < best:
            best, best_t = tot, float(t)
    return round(float(best_t), 4)