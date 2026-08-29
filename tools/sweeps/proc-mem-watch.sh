#!/bin/bash
PID="$1"
LOG="$2"
INTERVAL="${3:-10}"
while kill -0 "$PID" 2>/dev/null; do
  ts=$(date '+%H:%M:%S')
  vm=$(vmmap --summary "$PID" 2>/dev/null)
  gfx=$(echo "$vm" | awk '/IOAccelerator \(graphics\)/ {print $3}')
  total=$(echo "$vm" | awk '/^TOTAL / {print $3; exit}')
  rss=$(ps -o rss= -p "$PID" 2>/dev/null | tr -d ' ')
  echo "$ts gfx_resident=$gfx total_resident=$total rss_kb=$rss" >> "$LOG"
  sleep "$INTERVAL"
done
