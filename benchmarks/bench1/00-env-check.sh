#!/bin/bash
# Environment sanity: run before anything else and after any suspected problem.
echo "== wired limit (need 27000) =="
sysctl iogpu.wired_limit_mb
echo "== leftover servers (must be empty) =="
pgrep -fl "llama-server|mlx_lm" | grep -v pgrep || echo "none"
echo "== port 8081 =="
curl -s -m 2 -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8081/health || true
echo "== disk free =="
df -h / | tail -1
echo "== evalplus =="
command -v evalplus.codegen evalplus.evaluate 2>/dev/null || echo "NOT INSTALLED (run 01-install-evalplus.sh)"
echo "== models on disk =="
du -sh ~/.cache/huggingface/hub/models--* 2>/dev/null | sort -rh | head -8
