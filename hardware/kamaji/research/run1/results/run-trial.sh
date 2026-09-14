#!/bin/bash
#
# run-trial.sh — drive the whole goal-3 replay trial, both models.
#
# Twelve short runs: two models, two situations, three arms. It handles
# the runtime switch, which is the part that goes wrong by hand: gemma
# serves from LM Studio, the MLX Bonsai from mlx_lm.server, and the LM
# Studio APP must be quit between them, not merely unloaded. A loaded
# LM Studio keeps its MLX runtime host alive and puts a second MLX
# process on the GPU.
#
# Usage: run-trial.sh

set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
LMS="$HOME/.cache/lm-studio/bin/lms"
LOG="/tmp/toolcall-trial/driver.log"

mkdir -p /tmp/toolcall-trial


say() {
    echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG"
}


record_memory() {
    local label="$1"
    local free
    free=$(vm_stat | awk '/Pages free/ {gsub(/[ .]/,"",$3); print $3*16384/1048576}')
    local swap
    swap=$(sysctl -n vm.swapusage | awk '{print $6}')
    say "$label: free ${free%.*} MB, swap used $swap"
}


start_gemma() {
    say "loading gemma-4-12b in LM Studio"
    "$LMS" load google/gemma-4-12b --parallel 4 --gpu max -y > /dev/null 2>&1

    "$LMS" server start > /dev/null 2>&1

    if ! curl -s -m 5 http://127.0.0.1:1234/v1/models > /dev/null; then
        say "FAILED: LM Studio server is not answering"
        exit 1
    fi

    say "gemma ready"
}


stop_gemma() {
    say "unloading gemma and quitting the LM Studio app"
    "$LMS" unload --all > /dev/null 2>&1
    osascript -e 'quit app "LM Studio"' > /dev/null 2>&1
    sleep 8

    if pgrep -f "LM Studio" > /dev/null; then
        say "WARNING: an LM Studio process is still alive"
        pgrep -fl "LM Studio" | head -3 | tee -a "$LOG"
    else
        say "LM Studio fully stopped"
    fi
}


start_bonsai() {
    say "starting mlx_lm.server for the Bonsai"
    mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit \
        --prompt-cache-size 2 --port 8081 > /tmp/toolcall-trial/mlx-server.log 2>&1 &

    local waited=0
    while [ "$waited" -lt 300 ]; do
        if curl -s -m 3 http://127.0.0.1:8081/v1/models > /dev/null 2>&1; then
            say "Bonsai ready after ${waited}s"
            return 0
        fi
        sleep 10
        waited=$(( waited + 10 ))
    done

    say "FAILED: mlx_lm.server did not answer in 300s"
    tail -5 /tmp/toolcall-trial/mlx-server.log | tee -a "$LOG"
    exit 1
}


stop_bonsai() {
    say "stopping mlx_lm.server"
    pkill -f "mlx_lm.server" 2>/dev/null
    sleep 5
}


say "=== trial start ==="
record_memory "before"

start_gemma
bash "$HERE/replay-probe.sh" "google/gemma-4-12b" gemma12b 2>&1 | tee -a "$LOG"
record_memory "after gemma"
stop_gemma

record_memory "after LM Studio quit"

start_bonsai
bash "$HERE/replay-probe.sh" "prism-ml/Ternary-Bonsai-27B-mlx-2bit" bonsaimlx 2>&1 | tee -a "$LOG"
record_memory "after bonsai"
stop_bonsai

say "=== trial done ==="
python3 "$HERE/count-replay.py" 2>&1 | tee -a "$LOG"
