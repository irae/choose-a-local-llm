#!/usr/bin/env bash
set -u
kit=hardware/arrietty/benchmarks/bench33
prefix=$1
alias=$2
server_log=$3
for depth in 4096 8192 16384 24576 32768 49152 65536 81920 98304 114688 131072 147456 163840 180224 196608 212992 229376 245760 261120; do
  cell="$prefix-d$depth"
  if [ -f "$kit/results/$cell-exit-code.txt" ] && [ "$(cat "$kit/results/$cell-exit-code.txt")" = 0 ]; then
    continue
  fi
  /usr/bin/bash "$kit/results/s5-cell.sh" "$cell" "$depth" "$alias" "$server_log"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    exit "$rc"
  fi
  speed=$(awk -F'|' '/tg256/ {gsub(/[[:space:]]/,"",$4); split($4,a,"±"); print a[1]}' "$kit/results/$cell.md")
  if [ -n "$speed" ] && awk -v x="$speed" 'BEGIN {exit !(x < 8)}'; then
    exit 0
  fi
done
