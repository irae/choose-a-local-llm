#!/usr/bin/env bash
set -u
kit=hardware/arrietty/benchmarks/bench33
root=/home/irae/.t3/worktrees/choose-a-local-llm/t3-13bc8e56
runtime=/home/irae/.local/share/mise/installs/llama-cpp/b12110/llama-server
start_arm() {
  arm=$1
  alias=$2
  preset=$3
  server_log=$4
  old_unit=$5
  new_unit=$6
  systemctl --user stop "$old_unit" 2>/dev/null || true
  cp "$preset" "$kit/results/router.ini"
  systemd-run --user --no-block --unit="$new_unit" --property=Restart=no --working-directory="$root" --setenv=ROUTER_BIN="$runtime" --setenv=ROUTER_PRESET="$root/$kit/results/router.ini" --setenv=ROUTER_PORT=8888 --setenv=ROUTER_HOST=127.0.0.1 --setenv=ROUTER_MODELS_MAX=1 --setenv=ROUTER_IDLE=7200 /usr/bin/bash -lc "exec bash tools/llama-router.sh serve > $server_log 2>&1"
  ready=0
  for attempt in $(seq 1 120); do
    if curl -fsS "http://127.0.0.1:8888/health" >/dev/null; then ready=1; break; fi
    sleep 2
  done
  if [ "$ready" -ne 1 ]; then exit 70; fi
  nvidia-smi --query-gpu=memory.used,memory.free,temperature.gpu,power.draw --format=csv,noheader > "$kit/results/$arm-prewarm-vram.txt"
  free -m > "$kit/results/$arm-prewarm-host.txt"
  awk 'NR > 1 {sum += $4} END {printf "%d\n", sum + 0}' /proc/swaps > "$kit/results/$arm-prewarm-swap.txt"
  curl -fsS http://127.0.0.1:8888/v1/chat/completions -H 'Content-Type: application/json' -d "{\"model\":\"$alias\",\"messages\":[{\"role\":\"user\",\"content\":\"Summarize this request in one sentence.\"}],\"max_tokens\":64,\"temperature\":0}" > "$kit/results/$arm-prewarm-response.json"
  nvidia-smi --query-gpu=memory.used,memory.free,temperature.gpu,power.draw --format=csv,noheader >> "$kit/results/$arm-prewarm-vram.txt"
  free -m >> "$kit/results/$arm-prewarm-host.txt"
  awk 'NR > 1 {sum += $4} END {printf "%d\n", sum + 0}' /proc/swaps >> "$kit/results/$arm-prewarm-swap.txt"
  /usr/bin/bash "$kit/results/s5-curve.sh" "$arm-curve" "$alias" "$server_log"
}
while systemctl --user is-active --quiet s5-q8-f16-mtp1-curve.service; do sleep 15; done
start_arm s5-q8-f16-mtp2 s5-nano-q8-f16-mtp2 "$kit/results/router-s5-q8-f16-mtp2-c262144.ini" "$kit/results/server-s5-q8-f16-mtp2-c262144.log" s5-q8-f16-mtp1-c262144-router.service s5-q8-f16-mtp2-c262144-router.service
systemctl --user stop s5-q8-f16-mtp2-c262144-router.service 2>/dev/null || true
start_arm s5-q8-f16-nodraft s5-nano-q8-f16-nodraft "$kit/results/router-s5-q8-f16-nodraft-c262144.ini" "$kit/results/server-s5-q8-f16-nodraft-c262144.log" s5-q8-f16-mtp2-c262144-router.service s5-q8-f16-nodraft-c262144-router.service
systemctl --user stop s5-q8-f16-nodraft-c262144-router.service 2>/dev/null || true
