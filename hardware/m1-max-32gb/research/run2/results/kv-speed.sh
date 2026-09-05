#!/bin/bash
#
# kv-speed.sh — research run 2, follow-up to T2.1 (proposal P3).
#
# The context ramp measured 27.3 tokens per second on the vetted
# Gemma-12B llama-server configuration, where
# `docs/setups/m1-max-32gb/benchmarks/gemma-4-12b-it.md` publishes 45.0.
# Three things differ from the published run and any could carry the
# gap: q8_0 KV instead of f16, wired limit 24000 instead of 27000, and
# homebrew 0.3.0 instead of build 10621.
#
# This settles the first of the three. Same command, same prompts, same
# context; only the KV cache type changes. It cannot settle the other
# two: the build is what is installed, and the wired limit is the
# owner's.
#
# It uses the page's own two prompts and its own 256-token budget, so
# the numbers are comparable to the published table.
#
# What it changes on the Mac: nothing. One server at a time, started and
# stopped here. No download: --offline forces the cache. No setting is
# touched.
#
# Reverse direction: `pkill -f llama-server`.
#
# Owner step: none. It must run with the GPU free.

set -u

KV_TYPES="q8_0 f16"
CONTEXTS="32768 262144"

MODEL_REPO="unsloth/gemma-4-12b-it-GGUF:Q4_K_XL"
ALIAS="gemma-4-12b-it"
PORT=8081

PY_PROMPT="Write a Python function that parses ISO dates."
JS_PROMPT="Write a JavaScript function that deep clones an object."
PREDICT=256

OUT="/tmp/run2/kv-speed"
EVIDENCE="$HOME/.local/share/choose-a-local-llm/evidence/run2-kv-speed"
TSV="$OUT/kv-speed.tsv"


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
    printf 'kv_type\tcontext\tprompt\ttok_s\tprompt_tok_s\tdraft_acceptance\twired_mb\n' > "$TSV"
}

wired_mb() {
    vm_stat | awk '/Pages wired down/ {gsub("\\.","",$4); print int($4 * 16384 / 1048576)}'
}

start_server() {
    local kv="$1"
    local ctx="$2"
    local log="$3"

    llama-server \
        -hf "$MODEL_REPO" \
        --alias "$ALIAS" \
        --no-mmproj \
        --spec-type draft-mtp \
        --spec-draft-n-max 4 \
        --parallel 1 \
        -ngl 999 \
        -fa on \
        -c "$ctx" \
        --cache-type-k "$kv" \
        --cache-type-v "$kv" \
        --jinja \
        --offline \
        --port "$PORT" \
        > "$log" 2>&1 &

    SERVER_PID=$!
}

wait_for_server() {
    local waited=0
    while [ "$waited" -lt 420 ]; do
        if ! kill -0 "$SERVER_PID" 2>/dev/null; then
            return 1
        fi
        if curl -s -m 3 "http://127.0.0.1:$PORT/health" | grep -q '"ok"'; then
            return 0
        fi
        sleep 3
        waited=$(( waited + 3 ))
    done
    return 2
}

send_prompt() {
    local text="$1"
    curl -s -m 300 "http://127.0.0.1:$PORT/v1/chat/completions" \
        -H 'Content-Type: application/json' \
        -d "{\"model\":\"$ALIAS\",\"messages\":[{\"role\":\"user\",\"content\":\"$text\"}],\"max_tokens\":$PREDICT,\"temperature\":0}" \
        > /dev/null 2>&1
}

read_last_speed() {
    local log="$1"
    grep "        eval time" "$log" | tail -1 \
        | sed -E 's/.*, +([0-9.]+) tokens per second\)$/\1/'
}

read_last_prompt_speed() {
    local log="$1"
    grep "prompt eval time" "$log" | tail -1 \
        | sed -E 's/.*, +([0-9.]+) tokens per second\)$/\1/'
}

read_last_acceptance() {
    local log="$1"
    grep "draft acceptance" "$log" | tail -1 \
        | sed -E 's/.*draft acceptance = ([0-9.]+) .*/\1/'
}

run_one_arm() {
    local kv="$1"
    local ctx="$2"
    local log="$OUT/server-$kv-$ctx.log"

    echo "=== KV $kv, context $ctx ==="

    start_server "$kv" "$ctx" "$log"
    wait_for_server
    local status=$?

    if [ "$status" -ne 0 ]; then
        echo "  server did not serve, status $status"
        printf '%s\t%s\t%s\tna\tna\tna\tna\n' "$kv" "$ctx" "load-failed" >> "$TSV"
        kill "$SERVER_PID" 2>/dev/null
        wait "$SERVER_PID" 2>/dev/null
        return
    fi

    local wired
    wired=$(wired_mb)
    echo "  wired after load: ${wired} MB"

    send_prompt "$PY_PROMPT"
    sleep 2
    local py_speed
    py_speed=$(read_last_speed "$log")
    local py_prompt
    py_prompt=$(read_last_prompt_speed "$log")
    local py_accept
    py_accept=$(read_last_acceptance "$log")
    echo "  py: ${py_speed} tok/s, prompt ${py_prompt} tok/s, draft ${py_accept}"
    printf '%s\t%s\tpy\t%s\t%s\t%s\t%s\n' "$kv" "$ctx" "$py_speed" "$py_prompt" "$py_accept" "$wired" >> "$TSV"

    send_prompt "$JS_PROMPT"
    sleep 2
    local js_speed
    js_speed=$(read_last_speed "$log")
    local js_prompt
    js_prompt=$(read_last_prompt_speed "$log")
    local js_accept
    js_accept=$(read_last_acceptance "$log")
    echo "  js: ${js_speed} tok/s, prompt ${js_prompt} tok/s, draft ${js_accept}"
    printf '%s\t%s\tjs\t%s\t%s\t%s\t%s\n' "$kv" "$ctx" "$js_speed" "$js_prompt" "$js_accept" "$wired" >> "$TSV"

    kill "$SERVER_PID" 2>/dev/null
    wait "$SERVER_PID" 2>/dev/null
    cp "$log" "$EVIDENCE/"
    sleep 20
    echo "  wired after stop: $(wired_mb) MB"
    echo ""
}


check_gpu_is_free
make_directories

echo "KV speed A/B. Wired limit: $(sysctl -n iogpu.wired_limit_mb) MB."
echo ""

for kv in $KV_TYPES; do
    for ctx in $CONTEXTS; do
        run_one_arm "$kv" "$ctx"
    done
done

cp "$TSV" "$EVIDENCE/"
echo "Done. Table: $TSV"
