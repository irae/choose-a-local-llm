"""Build the MASSIVE pt-PT intent cases, with the authors' option rule.

Their rule (research/scripts/bench_local.py, `build_massive`): seed 13,
20 options, the gold label plus 19 distractors sampled from the other
labels, shuffled, and the option text is the label with `_` turned into
a space and `.` into `: `.
"""
import json
import random

from datasets import load_dataset

SEED, N_OPTS = 13, 20
d = load_dataset("mteb/amazon_massive_intent", "pt", split="test")
labels = sorted(set(d["label_text"]))
rng = random.Random(SEED)
out = "hardware/arrietty/research/run1/results/laya-portuguese/massive-pt.jsonl"
with open(out, "w") as f:
    for r in d:
        pool = [x for x in labels if x != r["label_text"]]
        keys = [r["label_text"]] + rng.sample(pool, min(N_OPTS - 1, len(pool)))
        rng.shuffle(keys)
        f.write(json.dumps({
            "state": {"utterance": r["text"]},
            "questions": {"intent": {
                "type": "choice",
                "instructions": "What is the user asking for in `utterance`?",
                "criteria": {k: k.replace("_", " ").replace(".", ": ") for k in keys}}},
            "labels": {"intent": r["label_text"]},
        }, ensure_ascii=False) + "\n")
print("cases", len(d), "labels", len(labels), "->", out)
