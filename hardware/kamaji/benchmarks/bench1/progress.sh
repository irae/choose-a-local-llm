#!/bin/bash
# One-glance progress: what is running, what is done, is generation advancing.
echo "== running processes =="
pgrep -fl "llama-server|mlx_lm|evalplus" | grep -v pgrep || echo "nothing running"
echo "== server health =="
curl -s -m 2 -o /dev/null -w "port 8081: %{http_code}\n" http://127.0.0.1:8081/health || true
echo "== results so far =="
for d in "$(dirname "$0")"/results/*/; do
  [ -d "$d" ] || continue
  N=$(basename "$d")
  S=$(grep -ihE "pass@1" "$d/evaluate.log" 2>/dev/null | tail -1)
  G=$(find "$d" -name "*.jsonl" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
  echo "$N: samples=${G:-0} score=${S:-incomplete}"
done
echo "== state file =="
cat "$(dirname "$0")/state.md" 2>/dev/null || echo "no state.md yet"
