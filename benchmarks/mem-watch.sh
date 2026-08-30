#!/bin/bash
# Small memory probe: one line every 5 min with free RAM and deltas of
# swap/compression counters, so slowdowns can be correlated with real
# swap/compression events (not just steady-state pressure color).
LOG="$(dirname "$0")/mem-watch.log"
PAGE=16384
INTERVAL="${MEMWATCH_INTERVAL:-300}"
prev_swapin=0; prev_swapout=0; prev_compress=0; prev_decompress=0; first=1

while true; do
  s=$(vm_stat)
  free=$(echo "$s" | awk '/Pages free/ {gsub("\\.",""); print $3}')
  swapin=$(vm_stat | awk '/Swapins/ {gsub("\\.",""); print $2}')
  swapout=$(vm_stat | awk '/Swapouts/ {gsub("\\.",""); print $2}')
  compress=$(echo "$s" | awk '/Compressions/ {gsub("\\.",""); print $2}')
  decompress=$(echo "$s" | awk '/Decompressions/ {gsub("\\.",""); print $2}')
  free_mb=$(( free * PAGE / 1024 / 1024 ))

  if [ "$first" = "1" ]; then
    d_swapin=0; d_swapout=0; d_compress=0; d_decompress=0
    first=0
  else
    d_swapin=$(( swapin - prev_swapin ))
    d_swapout=$(( swapout - prev_swapout ))
    d_compress=$(( compress - prev_compress ))
    d_decompress=$(( decompress - prev_decompress ))
  fi
  prev_swapin=$swapin; prev_swapout=$swapout; prev_compress=$compress; prev_decompress=$decompress

  echo "$(date '+%H:%M:%S') free_mb=$free_mb d_swapin=$d_swapin d_swapout=$d_swapout d_compress=$d_compress d_decompress=$d_decompress" >> "$LOG"
  sleep "$INTERVAL"
done
