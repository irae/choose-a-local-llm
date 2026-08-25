#!/bin/bash
# Night step 3 server: Ternary Bonsai 27B on mlx-lm, thinking on (its default).
bash "$(dirname "$0")/90-stop-servers.sh"
LOG=/tmp/night1-bonsai.log
nohup mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit --port 8081 > "$LOG" 2>&1 &
echo "started, log: $LOG"
for i in $(seq 1 90); do curl -s -m 2 -o /dev/null http://127.0.0.1:8081/v1/models && { echo up; exit 0; }; sleep 2; done
echo "FAILED to become healthy"; tail -5 "$LOG"; exit 1
