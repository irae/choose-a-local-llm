#!/bin/bash
#
# gemma-loop-sweep.sh — does gemma-4-12b loop on EVERY serving line, or
# only on some?
#
# Bonus task, 2026-09-03. The 72-call `ls -F_r` loop was recorded on one
# configuration, on a machine that was busy, at a context of 158464. Two
# of those three things have changed: the Mac is freshly rebooted and
# quiet, and this sweep drops the context to 8192 because the task needs
# nothing like the full window. So a line previously flagged bad is not
# skipped here — it may simply have been starved.
#
# Every command below is copied from a vetted source, with only the
# context lowered:
#   A  llama-server + MTP   docs/setups/m1-max-32gb/benchmarks/gemma-4-12b-it.md
#   B  llama-server no MTP  same page, the sweep configuration
#   C  LM Studio            benchmarks/bench7/AGENT.md
#
# The LM Studio MLX 4-bit line from the same page is NOT here: that model
# is absent from the LM Studio store and running it would download.
#
# HF_HUB_OFFLINE=1 guards the -hf flag so a tag that misses the cache
# fails instead of fetching.
#
# LM Studio runs last, and the app is quit afterwards, because its stack
# kernel-panicked this machine earlier today.
#
# Usage: gemma-loop-sweep.sh [runs-per-config]

set -u

RUNS="${1:-3}"
CONTEXT=8192
OUT="/tmp/gemma-loop-sweep"
WORK="$OUT/work"
GGUF_DIR="$HOME/.cache/huggingface/hub/models--unsloth--gemma-4-12b-it-GGUF"
LMS="$HOME/.cache/lm-studio/bin/lms"

mkdir -p "$OUT"


say() {
    echo "[$(date +%H:%M:%S)] $*"
}


build_workdir() {
    rm -rf "$WORK"
    mkdir -p "$WORK/lib/core"
    printf 'var xtend = require("xtend");\nmodule.exports = xtend;\n' \
        > "$WORK/lib/core/walker.js"
}


wait_for_port() {
    local url="$1"
    local waited=0

    while [ "$waited" -lt 300 ]; do
        if curl -s -m 3 "$url" > /dev/null 2>&1; then
            return 0
        fi
        sleep 10
        waited=$(( waited + 10 ))
    done

    return 1
}


start_llama_mtp() {
    say "A: llama-server with MTP, context $CONTEXT"
    HF_HUB_OFFLINE=1 nohup llama-server \
        -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
        --alias gemma-4-12b-it --no-mmproj \
        --spec-type draft-mtp --spec-draft-n-max 4 --parallel 1 \
        -ngl 999 -fa on -c "$CONTEXT" \
        --cache-type-k q8_0 --cache-type-v q8_0 \
        --jinja --port 8081 > "$OUT/server-A.log" 2>&1 &
}


start_llama_plain() {
    say "B: llama-server without MTP, context $CONTEXT"
    HF_HUB_OFFLINE=1 nohup llama-server \
        -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
        --alias gemma-4-12b-it --no-mmproj --parallel 1 \
        -ngl 999 -fa on -c "$CONTEXT" \
        --cache-type-k q8_0 --cache-type-v q8_0 \
        --jinja --port 8081 > "$OUT/server-B.log" 2>&1 &
}


stop_llama() {
    pkill -f "llama-server" 2>/dev/null
    sleep 5
}


start_lmstudio() {
    say "C: LM Studio, context $CONTEXT"
    "$LMS" load google/gemma-4-12b --context-length "$CONTEXT" \
        --gpu max -y > "$OUT/server-C.log" 2>&1
    "$LMS" server start >> "$OUT/server-C.log" 2>&1
}


stop_lmstudio() {
    "$LMS" unload --all > /dev/null 2>&1
    osascript -e 'quit app "LM Studio"' > /dev/null 2>&1
    sleep 8
    say "LM Studio processes left: $(pgrep -c -f 'LM Studio' 2>/dev/null || echo 0)"
}


PROMPT="List the contents of the packages/mendel-core directory in this project and tell me which files require the xtend module. Do not modify anything."


probe() {
    local tag="$1"
    local model="$2"
    local index=1

    while [ "$index" -le "$RUNS" ]; do
        local dir="$OUT/session-$tag-$index"
        rm -rf "$dir"
        mkdir -p "$dir"

        local started
        started=$(date +%s)

        build_workdir
        (cd "$WORK" && timeout 600 pi --print \
            --model "$model" \
            --session-dir "$dir" \
            "$PROMPT") > "$OUT/out-$tag-$index.txt" 2>&1

        say "  $tag run $index: exit $?, $(( $(date +%s) - started ))s"
        index=$(( index + 1 ))
    done
}


say "=== gemma-4-12b loop sweep, $RUNS runs per config, context $CONTEXT ==="
ls "$GGUF_DIR" > /dev/null 2>&1 || { say "GGUF not cached, stopping"; exit 1; }

stop_llama
stop_lmstudio

start_llama_mtp
if wait_for_port http://127.0.0.1:8081/v1/models; then
    probe A-llama-mtp gemma-4-12b
else
    say "A FAILED to serve"; tail -5 "$OUT/server-A.log"
fi
stop_llama

start_llama_plain
if wait_for_port http://127.0.0.1:8081/v1/models; then
    probe B-llama-plain gemma-4-12b
else
    say "B FAILED to serve"; tail -5 "$OUT/server-B.log"
fi
stop_llama

start_lmstudio
if wait_for_port http://127.0.0.1:1234/v1/models; then
    probe C-lmstudio google/gemma-4-12b
else
    say "C FAILED to serve"; tail -5 "$OUT/server-C.log"
fi
stop_lmstudio

say "=== done ==="
python3 "$(dirname "$0")/count-replay.py" "$OUT"
