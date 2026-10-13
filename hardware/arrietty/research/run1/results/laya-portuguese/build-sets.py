"""Build the three found Portuguese sets: topic, spam and sentiment.

Sampling: at most 2,000 cases per set, seed 0, stratified by label.
"""
import collections
import json
import random

from datasets import load_dataset

OUT = "hardware/arrietty/research/run1/results/laya-portuguese"
MAX = 2000


def stratified(rows, key, cap=MAX, seed=0):
    by = collections.defaultdict(list)
    for r in rows:
        by[key(r)].append(r)
    rng = random.Random(seed)
    for v in by.values():
        rng.shuffle(v)
    keys = sorted(by)
    take, i = [], 0
    while len(take) < min(cap, len(rows)):
        moved = False
        for k in keys:
            if i < len(by[k]) and len(take) < cap:
                take.append(by[k][i]); moved = True
        if not moved:
            break
        i += 1
    rng.shuffle(take)
    return take


def write(name, question, cases):
    qp = "%s/questions-%s.json" % (OUT, name)
    json.dump(question, open(qp, "w"), indent=2, ensure_ascii=False)
    dp = "%s/%s.jsonl" % (OUT, name)
    with open(dp, "w") as f:
        for state, label in cases:
            f.write(json.dumps({"state": state, "labels": label}, ensure_ascii=False) + "\n")
    counts = collections.Counter(tuple(sorted(l.items())) for _, l in cases)
    print("%s: %d cases -> %s" % (name, len(cases), dp))
    for k, v in counts.most_common():
        print("    %-60s %d" % (k, v))


# ---------------------------------------------------------------- topic: sib200
d = load_dataset("Davlan/sib200", "por_Latn")
rows = [r for split in d for r in d[split]]
cats = sorted(set(r["category"] for r in rows))
rows = stratified(rows, lambda r: r["category"])
write("sib200-topic",
      {"topic": {"type": "choice",
                 "instructions": "What is the topic of `text`?",
                 "criteria": {c: c.replace("/", " or ") for c in cats}}},
      [({"text": r["text"]}, {"topic": r["category"]}) for r in rows])

# ---------------------------------------------------------------- spam: SMS, pt column
d = load_dataset("dbarbedillo/SMS_Spam_Multilingual_Collection_Dataset", split="train")
rows = [r for r in d if (r.get("text_pt") or "").strip()]
rows = stratified(rows, lambda r: r["labels"])
write("sms-spam",
      {"is_spam": {"type": "noul",
                   "instructions": "Is this text message unsolicited spam or bulk marketing?"}},
      [({"message": r["text_pt"]}, {"is_spam": r["labels"] == "spam"}) for r in rows])

# ---------------------------------------------------------------- sentiment: b2w reviews
# The Hugging Face copy is a loader script, which `datasets` 5 no longer runs.
# The script's own source is this file, pinned at the commit it names.
B2W_CSV = ("https://raw.githubusercontent.com/americanas-tech/b2w-reviews01/"
           "4639429ec698d7821fc99a0bc665fa213d9fcd5a/B2W-Reviews01.csv")
# Some columns mix numbers and strings, so every column is read as text.
import pandas as pd

df = pd.read_csv(B2W_CSV, dtype=str)
rows = []
for _, r in df.iterrows():
    text = (r.get("review_text") or "").strip() if isinstance(r.get("review_text"), str) else ""
    try:
        rating = int(r.get("overall_rating"))
    except (TypeError, ValueError):
        continue
    if text and rating in (1, 2, 3, 4, 5):
        rows.append({"review_text": text, "overall_rating": rating})


def polarity(r):
    return "negative" if r["overall_rating"] <= 2 else "neutral" if r["overall_rating"] == 3 else "positive"


rows = stratified(rows, polarity)
write("b2w-sentiment",
      {"sentiment": {"type": "choice",
                     "instructions": "What is the opinion of the writer about the product in `review`?",
                     "criteria": {"negative": "unhappy with the product",
                                  "neutral": "neither happy nor unhappy",
                                  "positive": "happy with the product"}},
       "stars": {"type": "score",
                 "instructions": "How many stars out of five does the writer give the product?",
                 "criteria": ["one star", "two stars", "three stars", "four stars", "five stars"]}},
      [({"review": r["review_text"]},
        {"sentiment": polarity(r), "stars": r["overall_rating"] - 1}) for r in rows])
