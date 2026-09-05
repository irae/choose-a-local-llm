#!/bin/bash
# Flow rule 7: leftovers cleanup. Safe to run any time.
pkill -f llama-server 2>/dev/null
pkill -f mlx_lm.server 2>/dev/null
sleep 2
pgrep -fl "llama-server|mlx_lm" | grep -v pgrep || echo "clean"
