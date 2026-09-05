#!/bin/bash
#
# qwen38-ceiling.sh — research run 2, experiment T2.2 (AGENT.md
# section E). Re-probes the Qwen3.8-27B context ceiling on
# `mlx_lm.server` at the wired limit this session runs at.
#
# Why: the published ceiling of about 29K was measured at
# `iogpu.wired_limit_mb=25000`. The machine now runs at 24000, so
# `contextWindow` 26624 may no longer sit below the true ceiling.
#
# It uses the shared sweep tool, `tools/sweeps/mlx_sweep.py`, and adds
# nothing to it. The ramp goes UP one step at a time and stops at the
# first failure, because a fast walk drives the machine into swap and
# reports a ceiling no real session would hit.
#
# What it changes on the Mac: nothing. One server, started and stopped
# by this script. No download: HF_HUB_OFFLINE=1 forces the cache, the
# same guard llama-server gets from --offline. No setting is touched.
#
# Reverse direction: `pkill -f mlx_lm`. Nothing else is left behind.
#
# Owner step: none. It must run with the GPU free.

set -u

MODEL="mlx-community/Qwen3.8-27B-4bit"
PORT=8081

# One step at a time, starting below the published window and walking
# past the published ceiling. 26624 is the declared contextWindow and
# 29696 is where the old measurement put the ceiling.
DEPTHS="24576,26624,28672,29696,30720,32768"

OUT="/tmp/run2/qwen38-ceiling"
EVIDENCE="$HOME/.local/share/choose-a-local-llm/evidence/run2-qwen38-ceiling"
SERVER_LOG="$OUT/mlx-server.log"
SWEEP_LOG="$OUT/sweep.log"

REPO="$(cd "$(dirname "$0")/../../.." && pwd)"


check_gpu_is_free() {
    if pgrep -f "llama-server|mlx_lm" > /dev/null; then
        echo "abort: something is already serving; stop it first" >&2
        exit 1
    fi
    if pgrep -f "LM Studio" > /dev/null; then
        echo "abort: LM Studio is resident; quit the app first" >&2
        exit 1
    fi
    echo "GPU is free."
}

record_start() {
    mkdir -p "$OUT"
    mkdir -p "$EVIDENCE"
    echo "wired limit: $(sysctl -n iogpu.wired_limit_mb) MB"
    vm_stat | grep "Pages wired down"
    sysctl -n vm.swapusage
}

start_server() {
    HF_HUB_OFFLINE=1 \
    mlx_lm.server \
        --model "$MODEL" \
        --prompt-cache-size 2 \
        --port "$PORT" \
        > "$SERVER_LOG" 2>&1 &
    SERVER_PID=$!
    echo "mlx_lm.server pid $SERVER_PID, log $SERVER_LOG"
}

wait_for_server() {
    local waited=0
    while [ "$waited" -lt 480 ]; do
        if ! kill -0 "$SERVER_PID" 2>/dev/null; then
            echo "abort: mlx_lm.server died during load; see $SERVER_LOG" >&2
            tail -5 "$SERVER_LOG" >&2
            exit 1
        fi
        if curl -s -m 3 -o /dev/null "http://127.0.0.1:$PORT/v1/models"; then
            echo "Server ready after ${waited}s."
            return 0
        fi
        sleep 3
        waited=$(( waited + 3 ))
    done
    echo "abort: no /v1/models inside 480s" >&2
    exit 1
}

run_sweep() {
    MLOG="$SERVER_LOG" \
    MLX_MODEL="$MODEL" \
    DEPTH_LIST="$DEPTHS" \
    python3 "$REPO/tools/sweeps/mlx_sweep.py" 2>&1 | tee "$SWEEP_LOG"
    echo "sweep exit ${PIPESTATUS[0]}"
}

stop_server() {
    kill "$SERVER_PID" 2>/dev/null
    wait "$SERVER_PID" 2>/dev/null
    echo "server stopped"
}

report_memory_release() {
    local waited=0
    while [ "$waited" -lt 60 ]; do
        local wired
        wired=$(vm_stat | awk '/Pages wired down/ {gsub("\\.","",$4); print int($4 * 16384 / 1048576)}')
        echo "  wired ${wired} MB, ${waited}s after the kill"
        sleep 10
        waited=$(( waited + 10 ))
    done
}

archive() {
    cp "$SERVER_LOG" "$EVIDENCE/" 2>/dev/null
    cp "$SWEEP_LOG" "$EVIDENCE/" 2>/dev/null
    echo "evidence archived to $EVIDENCE"
}


check_gpu_is_free
record_start
start_server
wait_for_server
run_sweep
stop_server
report_memory_release
archive
echo "Qwen3.8 ceiling probe done. Sweep output: $SWEEP_LOG"
