#!/usr/bin/env python3
"""thinking-budget.py — the thinking budget of an EvalPlus run, and its proof.

A server that takes a thinking budget (`llama-server --reasoning-budget N
--reasoning-budget-message MSG`) closes the thinking at N tokens and the
model answers with what it has. This tool covers the three steps around
such a run:

  derive   <calibration.json>
      The two budgets from a calibration file: the thinking budget from the
      longest converged reasoning, the answer budget from the longest
      converged answer, each times the margin with a floor, and their sum
      as max_tokens.

  prepare  <run-dir> <rerun-dir> --message MSG
      After the budgeted run: list the problems where the budget message
      fired and the answer failed, copy the run's samples into <rerun-dir>
      without those problems, so `run-humaneval.sh` regenerates only them,
      at a generous budget and without the flag.

  report   <run-dir> <rerun-dir> --message MSG
      After the natural re-run: one line per forced problem with its cell,
      and the corrected thinking budget.

      forced-pass       the budget fired and the answer still passed
      forced-fail-late  the answer failed under the budget and passed
                        without it at N tokens: the budget was too small
      forced-fail-loop  the answer failed under the budget and hit the
                        generous budget without it: non-convergence
      forced-fail-wrong the answer failed both ways: the model's own limit

Reasoning tokens come from usage.completion_tokens_details when the server
reports them, else from completion_tokens split by the character ratio of
reasoning to answer.

Environment: THINKING_BUDGET_MARGIN (default 1.5), THINKING_BUDGET_FLOOR
(default 2048, applies to both budgets), THINKING_BUDGET_CAP (default 30000,
the thinking budget alone).
"""
import argparse
import glob
import json
import math
import os
import shutil
import sys

MARGIN = float(os.environ.get("THINKING_BUDGET_MARGIN", "1.5"))
FLOOR = int(os.environ.get("THINKING_BUDGET_FLOOR", "2048"))
CAP = int(os.environ.get("THINKING_BUDGET_CAP", "30000"))


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


def budget(value):
    return min(CAP, max(FLOOR, int(math.ceil(value * MARGIN))))


def derive(args):
    rows = json.load(open(args.calibration))
    converged = [r for r in rows if r.get("finish_reason") == "stop" and not r.get("content_empty")]
    cut = [r for r in rows if r.get("finish_reason") == "length"]
    if not converged:
        sys.exit("no converged answer in the calibration; nothing to derive")
    if not any(r.get("reasoning_len") for r in converged):
        sys.exit("the calibration records no reasoning length; re-run calibrate.py on the current tool")
    max_think = max(reasoning_tokens(r) for r in converged)
    max_answer = max(answer_tokens(r) for r in converged)
    think = budget(max_think)
    answer = max(FLOOR, int(math.ceil(max_answer * MARGIN)))
    print("converged\tcut\tmax_reasoning_tokens\tmax_answer_tokens\tthink_budget\tanswer_budget\tmax_tokens")
    print(f"{len(converged)}\t{len(cut)}\t{max_think}\t{max_answer}\t{think}\t{answer}\t{think + answer}")


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
        print(f"corrected_think_budget\t{budget(max(late))}\tfrom the longest late answer, {max(late)} reasoning tokens")
    else:
        print("corrected_think_budget\tunchanged\tno late answer")


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    d = sub.add_parser("derive")
    d.add_argument("calibration")
    d.set_defaults(fn=derive)
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
