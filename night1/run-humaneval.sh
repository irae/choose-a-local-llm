#!/bin/bash
# Usage: run-humaneval.sh <run-name> <model-id-as-served>
# Runs EvalPlus HumanEval+ generation + evaluation against localhost:8081.
# Results land in night1/results/<run-name>/.
# Flags may need adapting to the installed EvalPlus version: check
# `evalplus.codegen --help` on first failure.
set -e
NAME="$1"; MODEL="$2"
[ -z "$NAME" ] || [ -z "$MODEL" ] && { echo "usage: $0 <run-name> <model-id>"; exit 2; }
DIR="$(dirname "$0")/results/$NAME"
mkdir -p "$DIR"
export OPENAI_API_KEY=none
evalplus.codegen \
  --model "$MODEL" \
  --dataset humaneval \
  --backend openai \
  --base-url http://127.0.0.1:8081/v1 \
  --greedy \
  --max-new-tokens 3072 \
  --root "$DIR" 2>&1 | tee "$DIR/codegen.log"
SAMPLES=$(find "$DIR" -name "*.jsonl" | head -1)
evalplus.evaluate --dataset humaneval --samples "$SAMPLES" 2>&1 | tee "$DIR/evaluate.log"
echo "=== done: $NAME ==="
grep -iE "pass@|humaneval" "$DIR/evaluate.log" | tail -5
