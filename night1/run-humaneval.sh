#!/bin/bash
# Usage: run-humaneval.sh <run-name> <model-id-as-served> [extra-body-json]
# Runs EvalPlus HumanEval+ generation + evaluation against localhost:8081.
# Results land in night1/results/<run-name>/.
# extra-body-json (optional): merged into every chat completion request body,
# e.g. '{"chat_template_kwargs":{"reasoning_effort":"medium"}}' for mlx_lm.server.
# Flags may need adapting to the installed EvalPlus version: check
# `evalplus.codegen --help` on first failure.
set -e
set -o pipefail
NAME="$1"; MODEL="$2"; EXTRA_BODY="$3"
[ -z "$NAME" ] || [ -z "$MODEL" ] && { echo "usage: $0 <run-name> <model-id> [extra-body-json]"; exit 2; }
DIR="$(dirname "$0")/results/$NAME"
mkdir -p "$DIR"
export OPENAI_API_KEY=none
[ -n "$EXTRA_BODY" ] && export EVALPLUS_EXTRA_BODY="$EXTRA_BODY"
PYBIN="$(head -1 "$(command -v evalplus.codegen)" | sed 's/^#!//; s/ -E$//')"
"$PYBIN" "$(dirname "$0")/run_codegen_wrapper.py" \
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
