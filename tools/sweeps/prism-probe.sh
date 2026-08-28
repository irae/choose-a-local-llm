#!/bin/bash
set -u
LOG="/private/tmp/claude-501/-Users-irae-code-choose-a-local-llm/837313a9-f0ba-4b1c-8731-5926e194452d/scratchpad/prism-server-$1.log"
~/prism-llama/llama-server -m "/Users/irae/.cache/huggingface/hub/models--prism-ml--Ternary-Bonsai-27B-gguf/snapshots/abbae723028d71be674e71e1a71201a6f43fab22/Ternary-Bonsai-27B-PQ2_0.gguf" \
  --alias bonsai-prism \
  $2 \
  -ngl 999 -fa on -c 32768 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081 >"$LOG" 2>&1 &
PID=$!
up=0
for i in $(seq 1 120); do
  kill -0 "$PID" 2>/dev/null || break
  curl -s -m 2 http://127.0.0.1:8081/health | grep -q '"ok"' && { up=1; break; }
  sleep 2
done
if [ "$up" -ne 1 ]; then echo "LOAD-FAIL $1"; tail -5 "$LOG" | cut -c1-160; kill "$PID" 2>/dev/null; wait "$PID" 2>/dev/null; exit 1; fi
curl -s -m 300 http://127.0.0.1:8081/completion -d '{"prompt":"Write a Python function that parses ISO dates.","n_predict":256,"temperature":0}' >/dev/null
for lang in py js; do
  if [ "$lang" = py ]; then P="Write a Python function that parses ISO dates."; else P="Write a JavaScript function that deep clones an object."; fi
  R=$(curl -s -m 300 http://127.0.0.1:8081/completion -d "{\"prompt\":\"$P\",\"n_predict\":256,\"temperature\":0}")
  echo "TIMINGS $lang $(echo "$R" | /usr/bin/python3 -c 'import sys,json
try:
  t=json.load(sys.stdin).get("timings",{})
  print(json.dumps({k:t.get(k) for k in ("prompt_per_second","predicted_per_second","draft_n","draft_n_accepted")}))
except Exception as e: print("ERR",e)')"
done
RSS=$(ps -o rss= -p "$PID" | awk '{printf "%.1f GB", $1/1048576}')
echo "RESULT $1 rss=$RSS oom=$(grep -c OutOfMemory "$LOG")"
kill "$PID" 2>/dev/null; wait "$PID" 2>/dev/null
echo "server stopped"
