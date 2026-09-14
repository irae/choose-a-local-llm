#!/bin/bash
# Night step 1 server: Qwen3.8 MLX 4-bit, reasoning_effort=medium.
# CAVEAT: mlx_lm.server may not honor chat-template kwargs (effort would stay at
# default xhigh). VERIFY effort before the long run (see AGENT.md step 1).
# If effort cannot be set, use 11-server-qwen38-gguf-medium.sh instead.
bash "$(dirname "$0")/90-stop-servers.sh"
LOG=/tmp/bench1-qwen38-mlx.log
nohup mlx_lm.server --model mlx-community/Qwen3.8-27B-4bit --port 8081 > "$LOG" 2>&1 &
echo "started, log: $LOG"
for i in $(seq 1 90); do curl -s -m 2 -o /dev/null http://127.0.0.1:8081/v1/models && { echo up; exit 0; }; sleep 2; done
echo "FAILED to become healthy"; tail -5 "$LOG"; exit 1
