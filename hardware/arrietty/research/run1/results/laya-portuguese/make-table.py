"""Build the laya-portuguese table from the per-case answer files.

The fitted runs report the second half of the cases, so the shipped rows
are recomputed on that same half. The whole-set shipped number is
printed as its own column.
"""
import collections
import json
import math
import sys

import numpy as np

sys.path.insert(0, "scratchpad/laya-venv/lib/python3.12/site-packages")
from laya.common import ece_score  # noqa: E402

P = "hardware/arrietty/research/run1/results/laya-portuguese"
SETS = [("massive-pt", "MASSIVE pt intent", 20),
        ("sib200-topic", "SIB-200 topic", 7),
        ("sms-spam", "SMS spam", 2),
        ("b2w-sentiment", "B2W reviews", None)]
CKPTS = ["english", "multilingual", "typed-decisions"]


def rows_of(path):
    out = []
    with open(path) as f:
        for line in f:
            r = json.loads(line)
            if r["label_index"] is not None:
                out.append(r)
    return out


def score(rows):
    p = np.array([r["probs"][r["pred_index"]] for r in rows])
    correct = np.array([1.0 if r["pred_index"] == r["label_index"] else 0.0 for r in rows])
    brier = np.mean([((np.asarray(r["probs"]) - np.eye(len(r["probs"]))[r["label_index"]]) ** 2).sum()
                     for r in rows])
    majority = collections.Counter(r["label_index"] for r in rows).most_common(1)[0][1] / len(rows)
    return (len(rows), float(correct.mean()), majority, float(brier), ece_score(p, correct))


print("| set | question | checkpoint | cases | options | fitted | accuracy | majority class | Brier | ECE | temperature |")
print("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
for name, label, opts in SETS:
    for ck in CKPTS:
        shipped = rows_of("%s/answers/%s-%s-shipped.jsonl" % (P, name, ck))
        fitted = rows_of("%s/answers/%s-%s-fitted.jsonl" % (P, name, ck))
        half = (max(r["case"] for r in shipped) + 1) // 2
        qids = sorted(set(r["question"] for r in shipped))
        for qid in qids:
            for tag, rs in (("no", [r for r in shipped if r["question"] == qid and r["case"] >= half]),
                            ("yes", [r for r in fitted if r["question"] == qid and r["case"] >= half])):
                n, acc, maj, brier, ece = score(rs)
                k = len(rs[0]["probs"]) if opts is None else opts
                print("| %s | `%s` | `%s` | %d | %d | %s | %.4f | %.4f | %.4f | %.4f | %.3f |"
                      % (label, qid, ck, n, k, tag, acc, maj, brier, ece, rs[0]["temperature"]))
