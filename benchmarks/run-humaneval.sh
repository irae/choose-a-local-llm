#!/bin/bash
# General codegen/evaluate flow. Writes results under RESULTS_BASE
# (default: hardware/kamaji/benchmarks/bench5/results; set it to resume an older bench's
# results dir). Reuses benchmarks/run_codegen_wrapper.py unchanged
# (EVALPLUS_MAX_NEW_TOKENS, EVALPLUS_EXTRA_BODY). Run from the repo root.
#
# Usage: [RESULTS_BASE=hardware/kamaji/benchmarks/benchN/results] \
#   benchmarks/run-humaneval.sh <run-name> <model-id-as-served> [extra-body-json]
set -e
set -o pipefail
NAME="$1"; MODEL="$2"; EXTRA_BODY="$3"
[ -z "$NAME" ] || [ -z "$MODEL" ] && { echo "usage: $0 <run-name> <model-id> [extra-body-json]"; exit 2; }
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIR="$ROOT/${RESULTS_BASE:-hardware/kamaji/benchmarks/bench5/results}/$NAME"
mkdir -p "$DIR"
export OPENAI_API_KEY=none
[ -n "$EXTRA_BODY" ] && export EVALPLUS_EXTRA_BODY="$EXTRA_BODY"
export EVALPLUS_FINISH_LOG="${EVALPLUS_FINISH_LOG:-$DIR/finish.jsonl}"
PYBIN="$(head -1 "$(command -v evalplus.codegen)" | sed 's/^#!//; s/ -E$//')"
# EVALPLUS_CALIBRATION: a calibration answer that ended within the budget is
# the same text the run would produce at temperature 0, so it goes into the
# samples now and the run skips that problem instead of generating it again.
if [ -n "${EVALPLUS_CALIBRATION:-}" ]; then
  MODEL="$MODEL" DIR="$DIR" "$PYBIN" - <<'PYEOF'
import datetime, json, os
from evalplus.data import get_human_eval_plus
from evalplus.sanitize import sanitize

budget = int(os.environ.get("EVALPLUS_MAX_NEW_TOKENS", "3072"))
identifier = os.environ["MODEL"].strip("./").replace("/", "--") + "_openai_temp_0.0"
target = os.path.join(os.environ["DIR"], "humaneval", identifier + ".jsonl")
os.makedirs(os.path.dirname(target), exist_ok=True)
done = set()
if os.path.exists(target):
    with open(target) as f:
        done = {json.loads(l)["task_id"] for l in f if l.strip()}
problems = get_human_eval_plus()
rows = json.load(open(os.environ["EVALPLUS_CALIBRATION"]))
seeded = 0
for r in rows:
    content = r.get("content") or ""
    if r["task_id"] in done or r.get("finish_reason") != "stop" or not content.strip():
        continue
    if (r.get("completion_tokens") or budget + 1) > budget:
        continue
    task = problems[r["task_id"]]
    with open(target, "a") as f:
        f.write(json.dumps({"task_id": r["task_id"], "solution": sanitize(content, entrypoint=task["entry_point"])}) + "\n")
    with open(target.replace(".jsonl", ".raw.jsonl"), "a") as f:
        f.write(json.dumps({"task_id": r["task_id"], "solution": content}) + "\n")
    with open(os.environ["EVALPLUS_FINISH_LOG"], "a") as f:
        f.write(json.dumps({"utc": datetime.datetime.now(datetime.timezone.utc).isoformat(), "task_id": r["task_id"], "finish_reason": "stop", "completion_tokens": r["completion_tokens"], "wall_s": r.get("wall_s"), "source": "calibration"}) + "\n")
    seeded += 1
print(f"seeded {seeded} problems from the calibration")
PYEOF
fi
"$PYBIN" "$ROOT/benchmarks/run_codegen_wrapper.py" \
  --model "$MODEL" \
  --dataset humaneval \
  --backend openai \
  --base_url http://127.0.0.1:8081/v1 \
  --greedy \
  --root "$DIR" 2>&1 | tee "$DIR/codegen.log"
SAMPLES=$(find "$DIR" -name "*.jsonl" ! -name "*.raw.jsonl" | head -1)
evalplus.evaluate --dataset humaneval --samples "$SAMPLES" 2>&1 | tee "$DIR/evaluate.log"
echo "=== done: $NAME ==="
grep -iE "pass@|humaneval" "$DIR/evaluate.log" | tail -5
