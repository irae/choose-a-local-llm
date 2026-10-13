"""Build one case file per fast-mode HumanEval+ row.

State: the task prompt and the model's solution. Label: the plus-tests
result of the same task in the row's `*_eval_results.json`.
"""
import glob
import json
import os

from datasets import load_dataset

OUT = "hardware/arrietty/research/run1/results/laya-pass-gate"
prompts = {r["task_id"]: r["prompt"] for r in load_dataset("evalplus/humanevalplus", split="test")}

json.dump({"passes": {"type": "noul",
                      "instructions": "This solution passes the hidden tests."}},
          open("%s/questions-pass.json" % OUT, "w"), indent=2)

index = []
for sample in sorted(glob.glob("hardware/*/benchmarks/*/results/fast-*/humaneval/*_openai_temp_0.0.jsonl")):
    ev_path = sample.replace(".jsonl", "_eval_results.json")
    if not os.path.exists(ev_path):
        print("no eval results beside", sample)
        continue
    row = sample.split("/results/")[1].split("/")[0]
    ev = json.load(open(ev_path))["eval"]
    status = {tid: recs[0]["plus_status"] for tid, recs in ev.items()}
    cases, missing = [], 0
    for line in open(sample):
        s = json.loads(line)
        tid = s["task_id"]
        if tid not in status or tid not in prompts:
            missing += 1
            continue
        cases.append({"state": {"task": prompts[tid], "solution": s["solution"]},
                      "labels": {"passes": status[tid] == "pass"}})
    path = "%s/%s.jsonl" % (OUT, row)
    with open(path, "w") as f:
        for c in cases:
            f.write(json.dumps(c, ensure_ascii=False) + "\n")
    passes = sum(1 for c in cases if c["labels"]["passes"])
    index.append({"row": row, "sample": sample, "eval_results": ev_path,
                  "cases": len(cases), "missing": missing,
                  "pass_rate": round(passes / max(1, len(cases)), 4)})
    print("%-36s %3d cases  pass rate %.4f  missing %d" % (row, len(cases), passes / max(1, len(cases)), missing))
json.dump(index, open("%s/index.json" % OUT, "w"), indent=2)
