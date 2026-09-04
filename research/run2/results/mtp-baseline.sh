#!/bin/bash
#
# mtp-baseline.sh — research run 2, completes the P3 hypothesis in
# `kv-speed.md`.
#
# The published page records 22.3 tok/s without MTP and 45.0 py / 31.3 js
# with it. Our measured f16 arm reaches 31.95 py / 32.84 js: the js
# figure matches and exceeds the published one, only py is short. The
# hypothesis is that the whole difference is MTP draft acceptance, which
# no published row records.
#
# This measures the no-MTP baseline on this build. Two outcomes:
#   baseline near 22.3  -> the models agree without the drafter, so the
#                          gap is entirely drafter acceptance
#   baseline well below -> something else is slower and the hypothesis
#                          is wrong
#
# Same command as the vetted config with `--spec-type none` and f16 KV,
# the page's own two prompts, 256 tokens, temperature 0.
#
# What it changes on the Mac: nothing. One server, started and stopped
# here. No download: --offline forces the cache.
#
# Reverse direction: `pkill -f llama-server`.
#
# Owner step: none. Needs the GPU free. Takes about ten minutes.

set -u

MODEL_REPO="unsloth/gemma-4-12b-it-GGUF:Q4_K_XL"
ALIAS="gemma-4-12b-it"
PORT=8081
CONTEXT=262144

PY_PROMPT="Write a Python function that parses ISO dates."
JS_PROMPT="Write a JavaScript function that deep clones an object."
PREDICT=256

OUT="/tmp/run2/mtp-baseline"
EVIDENCE="$HOME/.local/share/choose-a-local-llm/evidence/run2-mtp-baseline"
LOG="$OUT/server.log"


check_gpu_is_free() {
    if pgrep -f "[l]lama-serv|[m]lx_lm" > /dev/null; then
        echo "abort: something is already serving; stop it first" >&2
        exit 1
    fi
    echo "GPU is free."
}

make_directories() {
    mkdir -p "$OUT"
    mkdir -p "$EVIDENCE"
}

start_server() {
    llama-server \
        -hf "$MODEL_REPO" \
        --alias "$ALIAS" \
        --no-mmproj \
        --spec-type none \
        --parallel 1 \
        -ngl 999 \
        -fa on \
        -c "$CONTEXT" \
        --cache-type-k f16 \
        --cache-type-v f16 \
        --jinja \
        --offline \
        --port "$PORT" \
        > "$LOG" 2>&1 &

    SERVER_PID=$!
    echo "llama-server pid $SERVER_PID, no drafter"
}

wait_for_server() {
    local waited=0
    while [ "$waited" -lt 420 ]; do
        if ! kill -0 "$SERVER_PID" 2>/dev/null; then
            echo "abort: server died during load" >&2
            tail -5 "$LOG" >&2
            exit 1
        fi
        if curl -s -m 3 "http://127.0.0.1:$PORT/health" | grep -q '"ok"'; then
            echo "Server ready after ${waited}s."
            return 0
        fi
        sleep 3
        waited=$(( waited + 3 ))
    done
    echo "abort: no /health inside 420s" >&2
    exit 1
}

send_prompt() {
    curl -s -m 300 "http://127.0.0.1:$PORT/v1/chat/completions" \
        -H 'Content-Type: application/json' \
        -d "{\"model\":\"$ALIAS\",\"messages\":[{\"role\":\"user\",\"content\":\"$1\"}],\"max_tokens\":$PREDICT,\"temperature\":0}" \
        > /dev/null 2>&1
}

read_last_speed() {
    grep "        eval time" "$LOG" | tail -1 \
        | sed -E 's/.*, +([0-9.]+) tokens per second\)$/\1/'
}

measure() {
    local label="$1"
    local text="$2"
    send_prompt "$text"
    sleep 2
    echo "  ${label}: $(read_last_speed) tok/s"
}

stop_server() {
    kill "$SERVER_PID" 2>/dev/null
    wait "$SERVER_PID" 2>/dev/null
    cp "$LOG" "$EVIDENCE/"
    echo "server stopped, log archived"
}


check_gpu_is_free
make_directories
echo "No-MTP baseline, f16 KV, context $CONTEXT."
start_server
wait_for_server
measure py "$PY_PROMPT"
measure js "$JS_PROMPT"
stop_server
echo "Done. Compare against the published 22.3 tok/s no-MTP figure."
