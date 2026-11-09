#!/usr/bin/env bash
set -u
kit=hardware/arrietty/benchmarks/bench33
cell=$1
depth=$2
alias=$3
server_log=$4
mem="$kit/results/$cell-memory.log"
log="$kit/results/$cell-stdout.log"
server="$kit/results/$cell-server-output.log"
metric_before="$kit/results/$cell-metrics-before.txt"
metric_after="$kit/results/$cell-metrics-after.txt"
offset="$kit/results/$cell-offset.txt"
now() { date --iso-8601=seconds; }
swap_kib() { awk 'NR > 1 {sum += $4} END {printf "%d", sum + 0}' /proc/swaps; }
snapshot() {
  nvidia-smi --query-gpu=memory.used,memory.free,temperature.gpu,power.draw --format=csv,noheader
  free -m
  cat /proc/swaps
}
printf 'allocation=%s depth=%s alias=%s\nbefore %s\nswap_used_before_kib=%s\n' "$(sed -n 's/^ctx-size = //p' "$kit/results/router.ini")" "$depth" "$alias" "$(now)" "$(swap_kib)" > "$mem"
snapshot >> "$mem"
curl -fsS "http://127.0.0.1:8888/metrics?model=$alias" > "$metric_before"
wc -c < "$server_log" > "$offset"
set +e
/home/irae/.local/bin/llama-benchy --base-url http://127.0.0.1:8888/v1 --model "$alias" --tokenizer /home/irae/.cache/huggingface/hub/models--maritaca-ai--S5-nano/snapshots/ae981dc208f3bba2939c4cf242fab3e9a83e4938 --book-url http://127.0.0.1:8089/corpus-mendel-js.txt --pp 512 --tg 256 --depth "$depth" --runs 2 --post-run-cmd 'sleep 5' --format md --save-result "$kit/results/$cell.md" > "$log" 2>&1
rc=$?
set -e
curl -fsS "http://127.0.0.1:8888/metrics?model=$alias" > "$metric_after"
snapshot >> "$mem"
printf 'after %s\nswap_used_after_kib=%s\n' "$(now)" "$(swap_kib)" >> "$mem"
offset_bytes=$(cat "$offset")
tail -c +$((offset_bytes + 1)) "$server_log" > "$server"
if [ "$(swap_kib)" -gt "$(sed -n 's/^swap_used_before_kib=//p' "$mem")" ]; then rc=42; fi
printf '%s\n' "$rc" > "$kit/results/$cell-exit-code.txt"
exit "$rc"
