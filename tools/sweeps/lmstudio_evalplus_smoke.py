import concurrent.futures, json, os, sys, time
import openai
from evalplus.data import get_human_eval_plus
from evalplus.sanitize import sanitize

# Concurrent EvalPlus smoke test against LM Studio: runs N real HumanEval
# problems at a chosen concurrency level (true simultaneous requests, not
# evalplus --bs which asks for N samples of ONE prompt). Records
# reasoning-token usage per problem so runs at different concurrency, and
# with/without thinking, can be compared directly.
#
# Run with the evalplus venv's python: needs evalplus + openai importable.
#   /Users/irae/.local/pipx/venvs/evalplus/bin/python3 lmstudio_evalplus_smoke.py \
#     <n_problems> <concurrency> <out_dir> [thinking:true|false|omit]

BASE = os.environ.get("SWEEP_BASE", "http://127.0.0.1:8081")
MODEL = os.environ.get("LMS_MODEL", "google/gemma-4-12b")
N_PROBLEMS = int(sys.argv[1]) if len(sys.argv) > 1 else 16
CONCURRENCY = int(sys.argv[2]) if len(sys.argv) > 2 else 1
OUT_DIR = sys.argv[3] if len(sys.argv) > 3 else "/tmp/gemma12-lmstudio-thinking-smoke"
THINKING = sys.argv[4] if len(sys.argv) > 4 else "omit"  # true | false | omit

INSTRUCTION_PREFIX = (
    "Please provide a self-contained Python script that solves the "
    "following problem in a markdown code block:"
)

client = openai.OpenAI(api_key="none", base_url=BASE + "/v1")

problems = get_human_eval_plus()
tasks = list(problems.items())[:N_PROBLEMS]

os.makedirs(OUT_DIR, exist_ok=True)
tag = f"c{CONCURRENCY}_think-{THINKING}"

def run_one(item):
    task_id, task = item
    message = INSTRUCTION_PREFIX + f"\n```python\n{task['prompt'].strip()}\n```"
    kwargs = dict(model=MODEL, messages=[{"role": "user", "content": message}],
                  max_tokens=16384, temperature=0)
    if THINKING != "omit":
        kwargs["extra_body"] = {"chat_template_kwargs": {"enable_thinking": THINKING == "true"}}
    t0 = time.time()
    resp = client.chat.completions.create(**kwargs)
    wall = time.time() - t0
    msg = resp.choices[0].message
    content = msg.content or ""
    reasoning = getattr(msg, "reasoning_content", None) or ""
    usage = resp.usage
    reasoning_tokens = 0
    if usage and usage.completion_tokens_details:
        reasoning_tokens = usage.completion_tokens_details.reasoning_tokens or 0
    solution = sanitize(content, entrypoint=task["entry_point"])
    return {
        "task_id": task_id,
        "solution": solution,
        "wall": wall,
        "completion_tokens": usage.completion_tokens if usage else None,
        "reasoning_tokens": reasoning_tokens,
        "reasoning_chars": len(reasoning),
        "finish_reason": resp.choices[0].finish_reason,
    }

t_start = time.time()
with concurrent.futures.ThreadPoolExecutor(max_workers=CONCURRENCY) as ex:
    results = list(ex.map(run_one, tasks))
t_total = time.time() - t_start

samples_path = os.path.join(OUT_DIR, f"{tag}.jsonl")
stats_path = os.path.join(OUT_DIR, f"{tag}.stats.jsonl")
with open(samples_path, "w") as f:
    for r in results:
        f.write(json.dumps({"task_id": r["task_id"], "solution": r["solution"]}) + "\n")
with open(stats_path, "w") as f:
    for r in results:
        f.write(json.dumps({k: v for k, v in r.items() if k != "solution"}) + "\n")

avg_reasoning = sum(r["reasoning_tokens"] for r in results) / len(results)
avg_completion = sum(r["completion_tokens"] or 0 for r in results) / len(results)
max_completion = max((r["completion_tokens"] or 0) for r in results)
print(f"tag={tag} n={len(results)} wall_total={t_total:.1f}s "
      f"avg_completion_tokens={avg_completion:.0f} max_completion_tokens={max_completion} "
      f"avg_reasoning_tokens={avg_reasoning:.0f}")
print(f"samples: {samples_path}")
