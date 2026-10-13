#!/bin/bash
#
# gpu-sample.sh — one line per second of what the card is doing, for the
# whole length of a test. Start it before the test, stop it after.
#
#   gpu-sample.sh <out.csv> [interval_seconds]
#
# Columns: unix time, memory used MB, memory total MB, GPU utilisation
# percent, memory-controller utilisation percent, power W, temperature C,
# graphics clock MHz. The memory figure is the whole card, so it holds
# the desktop's own use as well as the test's.
set -u
OUT="$1"
INTERVAL="${2:-1}"
echo "t,mem_used_mb,mem_total_mb,util_gpu_pct,util_mem_pct,power_w,temp_c,clock_mhz" > "$OUT"
while true; do
    line=$(nvidia-smi --query-gpu=memory.used,memory.total,utilization.gpu,utilization.memory,power.draw,temperature.gpu,clocks.current.graphics \
                      --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ')
    [ -n "$line" ] && echo "$(date +%s),$line" >> "$OUT"
    sleep "$INTERVAL"
done
