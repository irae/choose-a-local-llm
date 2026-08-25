#!/bin/bash
# Fallback for step 1: Qwen3.8 GGUF on llama-server with server-side medium effort.
# Scores the GGUF quant instead of MLX, at medium. 17.5 tok/s.
bash "$(dirname "$0")/90-stop-servers.sh"
LOG=/tmp/night1-qwen38-gguf.log
nohup llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 32768 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --reasoning-effort medium \
  --jinja --port 8081 > "$LOG" 2>&1 &
echo "started, log: $LOG"
for i in $(seq 1 120); do curl -s -m 2 -o /dev/null -w "" http://127.0.0.1:8081/health && { echo up; exit 0; }; sleep 2; done
echo "FAILED to become healthy"; tail -5 "$LOG"; exit 1
