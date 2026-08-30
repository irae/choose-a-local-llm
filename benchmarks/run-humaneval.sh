#!/bin/bash
# General codegen/evaluate flow. Writes results under RESULTS_BASE
# (default: benchmarks/bench5/results; set it to resume an older bench's
# results dir). Reuses benchmarks/run_codegen_wrapper.py unchanged
# (EVALPLUS_MAX_NEW_TOKENS, EVALPLUS_EXTRA_BODY). Run from the repo root.
#
# Usage: [RESULTS_BASE=benchmarks/benchN/results] \
#   benchmarks/run-humaneval.sh <run-name> <model-id-as-served> [extra-body-json]
set -e
set -o pipefail
NAME="$1"; MODEL="$2"; EXTRA_BODY="$3"
[ -z "$NAME" ] || [ -z "$MODEL" ] && { echo "usage: $0 <run-name> <model-id> [extra-body-json]"; exit 2; }
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIR="$ROOT/${RESULTS_BASE:-benchmarks/bench5/results}/$NAME"
mkdir -p "$DIR"
export OPENAI_API_KEY=none
[ -n "$EXTRA_BODY" ] && export EVALPLUS_EXTRA_BODY="$EXTRA_BODY"
PYBIN="$(head -1 "$(command -v evalplus.codegen)" | sed 's/^#!//; s/ -E$//')"
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
