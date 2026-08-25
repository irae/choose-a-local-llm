#!/bin/bash
# Night step 2 server: Qwen3.6-35B-A3B MoE, llama+MTP, thinking on (its default).
bash "$(dirname "$0")/90-stop-servers.sh"
LOG=/tmp/night1-qwen36.log
nohup llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 32768 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081 > "$LOG" 2>&1 &
echo "started, log: $LOG"
for i in $(seq 1 120); do curl -s -m 2 -o /dev/null -w "" http://127.0.0.1:8081/health && { echo up; exit 0; }; sleep 2; done
echo "FAILED to become healthy"; tail -5 "$LOG"; exit 1
