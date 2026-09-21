"""Build the laya-pass-gate table from the per-case answer files.

Both rows of a pair report the second half of the cases, the half the
fitted run reports, so the shipped and fitted numbers are comparable.
"""
import glob
import json
import os
import sys

import numpy as np

sys.path.insert(0, "scratchpad/laya-venv/lib/python3.12/site-packages")
from laya.common import ece_score  # noqa: E402

P = "hardware/arrietty/research/run1/results/laya-pass-gate"
index = {r["row"]: r for r in json.load(open("%s/index.json" % P))}


def rows_of(path):
    return [json.loads(l) for l in open(path)]


print("| model row | checkpoint | cases kept | left out | pass rate | fitted | gate accuracy at 0.5 | share called pass | Brier | ECE | temperature |")
print("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
for row in sorted(index):
    for ck in ("english", "multilingual", "typed-decisions"):
        shipped = rows_of("%s/answers/%s-%s-shipped.jsonl" % (P, row, ck))
        fitted = rows_of("%s/answers/%s-%s-fitted.jsonl" % (P, row, ck))
        kept = len(set(r["case"] for r in shipped))
        left_out = index[row]["cases"] - kept
        half = (max(r["case"] for r in shipped) + 1) // 2
        for tag, rs in (("no", [r for r in shipped if r["case"] >= half]),
                        ("yes", [r for r in fitted if r["case"] >= half])):
            y = np.array([float(r["label_index"]) for r in rs])
            p = np.array([r["probs"][1] for r in rs])
            pred = (p >= 0.5).astype(float)
            conf = np.array([r["probs"][r["pred_index"]] for r in rs])
            correct = (pred == y).astype(float)
            brier = float(np.mean((p - y) ** 2))
            print("| `%s` | `%s` | %d | %d | %.4f | %s | %.4f | %.4f | %.4f | %.4f | %.3f |"
                  % (row, ck, kept, left_out, y.mean(), tag, correct.mean(), pred.mean(), brier,
                     ece_score(conf, correct), rs[0]["temperature"]))
