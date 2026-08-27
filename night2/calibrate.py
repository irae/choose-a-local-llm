#!/usr/bin/env python3
# Night 2 Phase A: send a fixed 10-problem sample to a live server at a
# generous max_tokens cap, and record real completion sizes.
#
# Builds the chat message the same way EvalPlus's OpenAIChatDecoder does
# (evalplus/provider/openai.py + codegen.py), so the calibration reflects
# the real gate prompt, not an approximation.
#
# Usage: calibrate.py <config-name> <model-id> [extra-body-json]
import json
import os
import sys
import time

import openai

PROBLEM_IDS = [
    "HumanEval/0", "HumanEval/10", "HumanEval/26", "HumanEval/32",
    "HumanEval/38", "HumanEval/53", "HumanEval/76", "HumanEval/99",
    "HumanEval/124", "HumanEval/145",
]

INSTRUCTION_PREFIX = (
    "Please provide a self-contained Python script that solves the "
    "following problem in a markdown code block:"
)
SYSTEM_MSG = "You are a helpful assistant good at coding."

DATASET_PATH = os.path.expanduser(
    "~/Library/Caches/evalplus/HumanEvalPlus-v0.1.10.jsonl"
)


def load_problems():
    by_id = {}
    with open(DATASET_PATH) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            obj = json.loads(line)
            by_id[obj["task_id"]] = obj
    return by_id


def main():
    if len(sys.argv) < 3:
        print("usage: calibrate.py <config-name> <model-id> [extra-body-json]")
        sys.exit(2)
    config_name = sys.argv[1]
    model_id = sys.argv[2]
    extra_body = json.loads(sys.argv[3]) if len(sys.argv) > 3 else None

    problems = load_problems()
    client = openai.OpenAI(
        api_key="none", base_url="http://127.0.0.1:8081/v1", timeout=3600.0
    )

    out_path = f"night2/calibration-{config_name}.json"
    rows = []
    if os.path.exists(out_path):
        with open(out_path) as f:
            rows = json.load(f)
        done_ids = {r["task_id"] for r in rows}
        print(f"resuming: {len(done_ids)} rows already done", flush=True)
    else:
        done_ids = set()

    for task_id in PROBLEM_IDS:
        if task_id in done_ids:
            continue
        prob = problems[task_id]
        prompt = prob["prompt"]
        message = INSTRUCTION_PREFIX + f"\n```python\n{prompt.strip()}\n```"

        kwargs = {}
        if extra_body:
            kwargs["extra_body"] = extra_body

        t0 = time.time()
        resp = client.chat.completions.create(
            model=model_id,
            messages=[
                {"role": "system", "content": SYSTEM_MSG},
                {"role": "user", "content": message},
            ],
            max_tokens=30000,
            temperature=0,
            n=1,
            top_p=0.95,
            **kwargs,
        )
        dt = time.time() - t0

        choice = resp.choices[0]
        content = choice.message.content
        reasoning = getattr(choice.message, "reasoning_content", None) or getattr(
            choice.message, "reasoning", None
        )
        has_inline_think = bool(content) and "<think>" in content

        row = {
            "task_id": task_id,
            "completion_tokens": resp.usage.completion_tokens,
            "finish_reason": choice.finish_reason,
            "content_empty": not bool(content and content.strip()),
            "content_len": len(content) if content else 0,
            "has_separate_reasoning_field": bool(reasoning),
            "has_inline_think_tag": has_inline_think,
            "wall_s": round(dt, 1),
        }
        rows.append(row)
        print(json.dumps(row), flush=True)
        with open(out_path, "w") as f:
            json.dump(rows, f, indent=2)

    print(f"wrote {out_path}", flush=True)


if __name__ == "__main__":
    main()
