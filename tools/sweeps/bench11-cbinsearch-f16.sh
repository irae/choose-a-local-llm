#!/bin/bash
set -uo pipefail
C=$1
LOG=/Users/irae/code/choose-a-local-llm-run11/hardware/m1-max-32gb/benchmarks/bench11/results/server-qwen36-gguf-f16-c${C}.log
rm -f "$LOG"
cd /Users/irae/code/choose-a-local-llm-run11
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c "$C" \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline > "$LOG" 2>&1 &
PID=$!

DEADLINE=$((SECONDS+180))
RESULT=""
while [ $SECONDS -lt $DEADLINE ]; do
  if grep -q "listening on http" "$LOG" 2>/dev/null; then
    RESULT="loaded"
    break
  fi
  if grep -qiE "insufficient memory|error loading model|failed to allocate|kIOGPUCommandBufferCallbackErrorOutOfMemory" "$LOG" 2>/dev/null; then
    RESULT="failed-load"
    break
  fi
  if ! kill -0 "$PID" 2>/dev/null; then
    RESULT="died"
    break
  fi
  sleep 2
done

if [ "$RESULT" = "loaded" ]; then
  RESP=$(curl -s -m 240 http://127.0.0.1:8081/completion -H "Content-Type: application/json" \
    -d '{"prompt":"Write a Python function that parses ISO dates.","n_predict":512,"temperature":0}')
  echo "$RESP" > /tmp/bench11-f16-c${C}-completion.json
  if echo "$RESP" | grep -qi "insufficient memory\|error"; then
    RESULT="failed-completion"
  fi
fi

kill "$PID" 2>/dev/null
wait "$PID" 2>/dev/null

echo "CANDIDATE=$C RESULT=$RESULT"
