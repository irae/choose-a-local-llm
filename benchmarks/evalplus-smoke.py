#!/usr/bin/env python3
"""evalplus-smoke.py — the fast fixed EvalPlus subset for a research trial.

A research run tries a candidate container: a better quant of a model we
already run, or a smaller model claimed to match a larger one. It must
not run the full 164-problem gate; that is bench work and costs an hour
or more per config. This tool runs four fixed HumanEval+ problems
against a live server, with the same output budget on both sides, and
prints one line a second agent can read the same way.

It is not a score. It never reaches the site. It separates a broken
config from a working one. It cannot separate two good configs a few
tenths of a point apart: four problems have no resolution for that.
Only `benchmarks/run-humaneval.sh` produces a number we publish.

THE SUBSET, fixed here and not a parameter:

    HumanEval/53   passed by every scored config, shortest answers
    HumanEval/45   passed by every scored config, second shortest
    HumanEval/34   passed by every scored config, third shortest
    HumanEval/129  the problem with the most empty completions

The first three cost seconds each and every config we have ever scored
passes them, so a failure there means something changed. The fourth is
long reasoning: half of the scored configs return nothing for it. It is
in the subset so the smoke also sees the completion failure mode, not
only the wrong-answer one. Picked from the per-problem raw results and
`_eval_results.json` files under `hardware/m1-max-32gb/benchmarks/bench*/results/`, across
the twelve configs with a complete scored run.

THE BUDGET RULE. Both sides of a comparison use the SAME `max_tokens`,
taken from the calibration file of the config we run TODAY. Never
calibrate the candidate. A candidate that needs a bigger budget to pass
is a candidate that costs more, and the smoke must show that.
`SMOKE_CALIBRATION` points at that file and the budget follows the
method page: observed max completion x 1.5, floor 8192. When the
current config never converges (`finish_reason: length` in its
calibration), that rule does not apply: the budget is a waste-limiter
and the method page says to set it by hand. The tool refuses to guess
one. Pass it in `SMOKE_MAX_TOKENS` and use the same value on both
sides.

THE READING RULE. Run the tool twice: once against the config we run
today, once against the candidate, same budget, same server port, one
at a time. Compare the two SMOKE lines.

    LEVEL   same `passed`, same `empty`.
    BETTER  candidate `passed` is higher and `empty` is not higher.
    WORSE   candidate `passed` is lower, or `passed` is equal and
            `empty` is higher.
    NO VERDICT  any other mix, for example more passes and more
            empties. Say so, and run the full gate if the candidate
            still looks worth an hour.

Two more rules that stop a wrong reading:

- A difference of one problem is one problem out of four. Never turn it
  into a percentage and never write it beside a pass@1 number.
- LEVEL is not evidence that the candidate is as good. It is only
  evidence that the candidate is not broken.

USAGE. Run from the repo root, with the EvalPlus venv's python (the
tool imports evalplus and openai, and calls `evalplus.evaluate`):

    SMOKE_CALIBRATION=benchmarks/calibration-<current-config>.json \\
      benchmarks/evalplus-smoke.py <label> <model-id-as-served> [extra-body-json]

The third argument is the same extra body `run-humaneval.sh` takes; it
carries `chat_template_kwargs` for a thinking toggle.

ENVIRONMENT

    SMOKE_CALIBRATION  calibration file of the config we run today.
                       Required, unless SMOKE_MAX_TOKENS is set.
    SMOKE_MAX_TOKENS   budget override, for the waste-limiter case.
                       Use the same value on both sides.
    SMOKE_BASE         server base URL, default http://127.0.0.1:8081
    SMOKE_OUT          directory for the samples and evaluator files.
                       Default: a new temporary directory, printed.
    SMOKE_TIMEOUT_S    client timeout in seconds, default 7200. The
                       OpenAI SDK's ~600 s default cuts off a long but
                       legitimate completion.

WHAT IT CHANGES ON THE MACHINE. It writes three files in SMOKE_OUT and
nothing else. It sends requests to a server you already started. To
reverse it, delete SMOKE_OUT.

WHY IT PADS. `evalplus.evaluate` asserts full dataset coverage, so the
samples file carries the four real answers plus a `raise
NotImplementedError` stub for the other 160 problems. The pass@1 the
evaluator prints is therefore meaningless and this tool ignores it; the
verdict comes from the per-problem statuses. The same padding produced
`hardware/m1-max-32gb/benchmarks/bench3/results/gemma12-lmstudio-thinking-smoke/`.

VALIDATION. Replaces `tools/sweeps/lmstudio_evalplus_smoke.py`, whose
concurrency and reasoning-token capture live on here. Validate it, as
the method page says, against two configs whose full EvalPlus scores are
known, and against one config run twice.
"""
import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time

SUBSET = ["HumanEval/53", "HumanEval/45", "HumanEval/34", "HumanEval/129"]
STUB = "raise NotImplementedError"
INSTRUCTION_PREFIX = (
    "Please provide a self-contained Python script that solves the "
    "following problem in a markdown code block:"
)
SYSTEM_MSG = "You are a helpful assistant good at coding."
BUDGET_FLOOR = 8192
BUDGET_FACTOR = 1.5


def parse_args():
    p = argparse.ArgumentParser(
        prog="benchmarks/evalplus-smoke.py",
        description=(
            "Run the fixed four-problem EvalPlus smoke against a live "
            "server. Not a score: read the SMOKE line as level, better "
            "or worse against a second run at the same budget."
        ),
        epilog=(
            "environment: SMOKE_CALIBRATION (required unless "
            "SMOKE_MAX_TOKENS is set), SMOKE_MAX_TOKENS, SMOKE_BASE "
            "(default http://127.0.0.1:8081), SMOKE_OUT, "
            "SMOKE_TIMEOUT_S (default 7200)"
        ),
    )
    p.add_argument("label", help="name of this side, for example current or candidate")
    p.add_argument("model_id", help="model id as the server serves it")
    p.add_argument(
        "extra_body",
        nargs="?",
        help="JSON object merged into every request, as run-humaneval.sh takes it",
    )
    return p.parse_args()


def resolve_budget():
    override = os.environ.get("SMOKE_MAX_TOKENS")
    if override:
        print(f"event\tbudget\tsource=SMOKE_MAX_TOKENS\tmax_tokens={int(override)}")
        return int(override)
    path = os.environ.get("SMOKE_CALIBRATION")
    if not path:
        sys.exit(
            "SMOKE_CALIBRATION is not set. Point it at the calibration file of "
            "the config you run today, or set SMOKE_MAX_TOKENS to the budget "
            "that config already uses. The budget is never calibrated for the "
            "candidate."
        )
    if not os.path.exists(path):
        sys.exit(f"SMOKE_CALIBRATION file not found: {path}")
    with open(path) as f:
        rows = json.load(f)
    observed = max(int(r["completion_tokens"]) for r in rows)
    truncated = [r["task_id"] for r in rows if r.get("finish_reason") == "length"]
    if truncated:
        sys.exit(
            "the calibration has finish_reason=length on "
            + ",".join(truncated)
            + ". This config never converges, so its budget is a waste-limiter "
            "and the x1.5 rule does not apply. Set SMOKE_MAX_TOKENS by hand to "
            "the budget the scored run used, and use the same value on both "
            "sides."
        )
    budget = max(BUDGET_FLOOR, int(observed * BUDGET_FACTOR))
    print(
        f"event\tbudget\tsource={path}\tobserved_max={observed}\t"
        f"max_tokens={budget}"
    )
    return budget


def generate(client, sanitize, problems, model_id, budget, extra_body):
    rows = []
    for task_id in SUBSET:
        prob = problems[task_id]
        message = INSTRUCTION_PREFIX + f"\n```python\n{prob['prompt'].strip()}\n```"
        kwargs = {"extra_body": extra_body} if extra_body else {}
        t0 = time.time()
        resp = client.chat.completions.create(
            model=model_id,
            messages=[
                {"role": "system", "content": SYSTEM_MSG},
                {"role": "user", "content": message},
            ],
            max_tokens=budget,
            temperature=0,
            n=1,
            top_p=0.95,
            **kwargs,
        )
        wall = time.time() - t0
        choice = resp.choices[0]
        content = choice.message.content or ""
        reasoning = getattr(choice.message, "reasoning_content", None) or getattr(
            choice.message, "reasoning", None
        )
        reasoning_tokens = 0
        details = getattr(resp.usage, "completion_tokens_details", None)
        if details is not None:
            reasoning_tokens = getattr(details, "reasoning_tokens", 0) or 0
        if not reasoning_tokens and reasoning:
            reasoning_tokens = -1
        row = {
            "task_id": task_id,
            "solution": sanitize(content, entrypoint=prob["entry_point"]),
            "empty": not content.strip(),
            "completion_tokens": resp.usage.completion_tokens if resp.usage else 0,
            "reasoning_tokens": reasoning_tokens,
            "finish_reason": choice.finish_reason,
            "wall_s": round(wall, 1),
        }
        rows.append(row)
        print(
            f"event\tgenerated\t{task_id}\tempty={str(row['empty']).lower()}\t"
            f"completion_tokens={row['completion_tokens']}\t"
            f"finish_reason={row['finish_reason']}\twall_s={row['wall_s']}",
            flush=True,
        )
    return rows


def evaluate(rows, all_task_ids, out_dir, label):
    samples = os.path.join(out_dir, f"{label}.smoke.jsonl")
    by_id = {r["task_id"]: r for r in rows}
    with open(samples, "w") as f:
        for task_id in all_task_ids:
            row = by_id.get(task_id)
            solution = row["solution"] if row else STUB
            f.write(json.dumps({"task_id": task_id, "solution": solution or STUB}) + "\n")
    results = samples.replace(".jsonl", "_eval_results.json")
    if os.path.exists(results):
        os.remove(results)
    if shutil.which("evalplus.evaluate") is None:
        sys.exit(
            "evalplus.evaluate is not on PATH. Run this tool with the EvalPlus "
            "venv's python, the same one benchmarks/run-humaneval.sh uses."
        )
    print(f"event\tevaluating\t{samples}", flush=True)
    log = subprocess.run(
        ["evalplus.evaluate", "--dataset", "humaneval", "--samples", samples],
        capture_output=True,
        text=True,
    )
    with open(os.path.join(out_dir, f"{label}.evaluate.log"), "w") as f:
        f.write(log.stdout + log.stderr)
    if not os.path.exists(results):
        sys.exit(
            f"evalplus.evaluate wrote no results. Its log is in {out_dir}."
        )
    return json.load(open(results))["eval"]


def main():
    args = parse_args()
    extra_body = json.loads(args.extra_body) if args.extra_body else None
    budget = resolve_budget()
    base = os.environ.get("SMOKE_BASE", "http://127.0.0.1:8081")
    timeout = float(os.environ.get("SMOKE_TIMEOUT_S", "7200"))
    out_dir = os.environ.get("SMOKE_OUT") or tempfile.mkdtemp(prefix="evalplus-smoke-")
    os.makedirs(out_dir, exist_ok=True)
    print(f"event\tstart\tlabel={args.label}\tmodel={args.model_id}\tbase={base}\tout={out_dir}")

    import openai
    from evalplus.data import get_human_eval_plus
    from evalplus.sanitize import sanitize

    problems = get_human_eval_plus()
    missing = [t for t in SUBSET if t not in problems]
    if missing:
        sys.exit(f"dataset does not carry {missing}; the subset is fixed by task id")
    client = openai.OpenAI(api_key="none", base_url=base + "/v1", timeout=timeout)

    t0 = time.time()
    rows = generate(client, sanitize, problems, args.model_id, budget, extra_body)
    verdicts = evaluate(rows, list(problems), out_dir, args.label)
    total_wall = time.time() - t0

    print("task_id\tbase\tplus\tempty\tcompletion_tokens\treasoning_tokens\tfinish_reason\twall_s")
    passed = 0
    for row in rows:
        entry = verdicts[row["task_id"]][0]
        if entry["plus_status"] == "pass":
            passed += 1
        print(
            f"{row['task_id']}\t{entry['base_status']}\t{entry['plus_status']}\t"
            f"{str(row['empty']).lower()}\t{row['completion_tokens']}\t"
            f"{row['reasoning_tokens']}\t{row['finish_reason']}\t{row['wall_s']}"
        )
    empties = sum(1 for r in rows if r["empty"])
    tokens = sum(r["completion_tokens"] for r in rows)
    print(
        f"SMOKE\tlabel={args.label}\tproblems={len(rows)}\tpassed={passed}\t"
        f"empty={empties}\tcompletion_tokens={tokens}\tmax_tokens={budget}\t"
        f"wall_s={round(total_wall, 1)}\tout={out_dir}"
    )
    print(
        "event\tread\tcompare this SMOKE line with the other side's line at the "
        "same max_tokens: level (same passed, same empty), better (passed "
        "higher, empty not higher), worse (passed lower, or passed equal and "
        "empty higher), otherwise no verdict"
    )


if __name__ == "__main__":
    main()
