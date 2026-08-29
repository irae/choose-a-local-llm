#!/bin/bash
# Night 3 block 4 server: Gemma-4-26B-A4B MLX, thinking on (default).
bash "$(dirname "$0")/../night1/90-stop-servers.sh"
LOG=/tmp/night3-gemma26-mlx.log
nohup mlx_lm.server --model mlx-community/gemma-4-26b-a4b-it-4bit \
  --prompt-cache-size 2 --port 8081 > "$LOG" 2>&1 &
echo "started, log: $LOG"
for i in $(seq 1 120); do curl -s -m 2 -o /dev/null http://127.0.0.1:8081/v1/models && { echo up; exit 0; }; sleep 2; done
echo "FAILED to become healthy"; tail -5 "$LOG"; exit 1
