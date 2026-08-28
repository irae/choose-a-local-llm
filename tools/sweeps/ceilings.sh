#!/bin/bash
set -u
D="/private/tmp/claude-501/-Users-irae-code-choose-a-local-llm/837313a9-f0ba-4b1c-8731-5926e194452d/scratchpad"

echo "=== LEG 1: gemma26-mlx ceiling (past 74K) ==="
MLOG="$D/ceil-gemma26-mlx.log"
mlx_lm.server --model mlx-community/gemma-4-26b-a4b-it-4bit --prompt-cache-size 2 --port 8081 >"$MLOG" 2>&1 &
P=$!
for i in $(seq 1 240); do kill -0 $P 2>/dev/null || break; curl -s -m 2 -o /dev/null http://127.0.0.1:8081/v1/models && break; sleep 2; done
MLOG="$MLOG" MLX_MODEL="mlx-community/gemma-4-26b-a4b-it-4bit" DEPTH_LIST="81920,98304,114688,131072,147456" /usr/bin/python3 "$D/mlx_sweep.py" || echo "leg1 exit $?"
kill $P 2>/dev/null; wait $P 2>/dev/null; sleep 5

echo "=== LEG 2: gemma12 via LM Studio ceiling (past 74K) ==="
L=~/.cache/lm-studio/bin/lms
$L server start --port 1234 >/dev/null 2>&1
$L load "lmstudio-community/gemma-4-12B-it-MLX-4bit" --context-length 163840 --gpu max --yes >/dev/null 2>&1
sleep 5
SWEEP_BASE="http://127.0.0.1:1234" MLX_MODEL="gemma-4-12b-it-mlx" MLOG="" DEPTH_LIST="81920,98304,114688,131072,147456" /usr/bin/python3 "$D/mlx_sweep.py" || echo "leg2 exit $?"
$L unload --all >/dev/null 2>&1; $L server stop >/dev/null 2>&1; sleep 5

echo "=== LEG 3: qwen36-mlx ceiling bracket (33-41K) ==="
MLOG="$D/ceil-qwen36-mlx.log"
mlx_lm.server --model mlx-community/Qwen3.6-35B-A3B-4bit --prompt-cache-size 2 --port 8081 >"$MLOG" 2>&1 &
P=$!
for i in $(seq 1 240); do kill -0 $P 2>/dev/null || break; curl -s -m 2 -o /dev/null http://127.0.0.1:8081/v1/models && break; sleep 2; done
MLOG="$MLOG" MLX_MODEL="mlx-community/Qwen3.6-35B-A3B-4bit" DEPTH_LIST="32768,36864,40960" /usr/bin/python3 "$D/mlx_sweep.py" || echo "leg3 exit $?"
kill $P 2>/dev/null; wait $P 2>/dev/null; sleep 5

echo "=== LEG 4: bonsai-mlx ceiling bracket (49-65K) ==="
MLOG="$D/ceil-bonsai-mlx.log"
mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit --prompt-cache-size 2 --port 8081 >"$MLOG" 2>&1 &
P=$!
for i in $(seq 1 240); do kill -0 $P 2>/dev/null || break; curl -s -m 2 -o /dev/null http://127.0.0.1:8081/v1/models && break; sleep 2; done
MLOG="$MLOG" MLX_MODEL="prism-ml/Ternary-Bonsai-27B-mlx-2bit" DEPTH_LIST="49152,53248,57344,61440" /usr/bin/python3 "$D/mlx_sweep.py" || echo "leg4 exit $?"
kill $P 2>/dev/null; wait $P 2>/dev/null

pgrep -fl "llama-server|mlx_lm" || echo "all stopped"
