#!/bin/bash
set -u
DIR="/private/tmp/claude-501/-Users-irae-code-choose-a-local-llm/837313a9-f0ba-4b1c-8731-5926e194452d/scratchpad"
CFG="$1"

case "$CFG" in
  bonsai)        KIND=mlx;   MODEL="prism-ml/Ternary-Bonsai-27B-mlx-2bit"; DEPTHS="4096,8192,16384,24576,32768,49152,65536,81920,98304,131072,163840,196608,229376,258048";;
  qwen38-mlx)    KIND=mlx;   MODEL="mlx-community/Qwen3.8-27B-4bit";       DEPTHS="8192,16384,24576,28672";;
  qwen36-mlx)    KIND=mlx;   MODEL="mlx-community/Qwen3.6-35B-A3B-4bit";   DEPTHS="4096,8192,16384,24576,32768,40960,49152,61440,73728";;
  gemma26-mlx)   KIND=mlx;   MODEL="mlx-community/gemma-4-26b-a4b-it-4bit"; DEPTHS="4096,8192,16384,24576,32768,40960,49152,61440,73728";;
  gemma12-mlx)   KIND=mlx;   MODEL="mlx-community/gemma-4-12B-it-4bit";    DEPTHS="4096,8192,16384,24576,32768,40960,49152,61440,73728";;
  gemma26)       KIND=llama; HF="unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL"; NMAX=2; CTX=131072; DEPTHS="4096,8192,16384,24576,32768,40960,49152,65536,81920,98304,114688";;
  gemma12)       KIND=llama; HF="unsloth/gemma-4-12b-it-GGUF:Q4_K_XL";        NMAX=4; CTX=131072; DEPTHS="4096,8192,16384,24576,32768,49152,65536,81920,98304,114688";;
  qwen38-llama)  KIND=llama; HF="bartowski/Qwen3.8-27B-GGUF:Q4_K_M";          NMAX=3; CTX=65536;  DEPTHS="4096,8192,16384,24576,32768,49152,61440";;
  qwen36)        KIND=llama; HF="unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL"; NMAX=3; CTX=65536; DEPTHS="4096,8192,16384,24576,32768,40960,49152,61440";;
  *) echo "unknown config: $CFG"; exit 2;;
esac

LOG="$DIR/sweep3-$CFG.log"
echo "=== $CFG ($KIND) ==="
if [ "$KIND" = llama ]; then
  llama-server -hf "$HF" --alias "$CFG" --no-mmproj \
    --spec-type draft-mtp --spec-draft-n-max "$NMAX" --parallel 1 \
    -ngl 999 -fa on -c "$CTX" \
    --cache-type-k q8_0 --cache-type-v q8_0 \
    --jinja --port 8081 >"$LOG" 2>&1 &
  PID=$!
  up=0
  for i in $(seq 1 240); do
    kill -0 "$PID" 2>/dev/null || break
    curl -s -m 2 http://127.0.0.1:8081/health | grep -q '"ok"' && { up=1; break; }
    sleep 2
  done
  if [ "$up" -ne 1 ]; then echo "LOAD-FAIL"; grep -i -m2 OutOfMemory "$LOG"; kill "$PID" 2>/dev/null; wait "$PID" 2>/dev/null; exit 1; fi
  sleep 5
  DEPTH_LIST="$DEPTHS" /usr/bin/python3 "$DIR/llama_sweep.py"
  grep -qi OutOfMemory "$LOG" && echo "WARN: OOM lines in log"
  RSS=$(ps -o rss= -p "$PID" | awk '{printf "%.1f GB", $1/1048576}')
  echo "RSS: $RSS"
  kill "$PID" 2>/dev/null; wait "$PID" 2>/dev/null
else
  mlx_lm.server --model "$MODEL" --prompt-cache-size 2 --port 8081 >"$LOG" 2>&1 &
  PID=$!
  up=0
  for i in $(seq 1 240); do
    kill -0 "$PID" 2>/dev/null || break
    curl -s -m 2 -o /dev/null http://127.0.0.1:8081/v1/models && { up=1; break; }
    sleep 2
  done
  if [ "$up" -ne 1 ]; then echo "LOAD-FAIL"; kill "$PID" 2>/dev/null; exit 1; fi
  sleep 5
  MLOG="$LOG" MLX_MODEL="$MODEL" DEPTH_LIST="$DEPTHS" /usr/bin/python3 "$DIR/mlx_sweep.py"
  RSS=$(ps -o rss= -p "$PID" | awk '{printf "%.1f GB", $1/1048576}')
  echo "RSS: $RSS"
  kill "$PID" 2>/dev/null; wait "$PID" 2>/dev/null
fi
pgrep -fl "llama-server|mlx_lm" >/dev/null || echo "server stopped"
