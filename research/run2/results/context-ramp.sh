#!/bin/bash
#
# context-ramp.sh — research run 2, experiment T2.1 (AGENT.md section F).
#
# What it does: starts llama-server once per context size with the MTP
# drafter enabled, sends one warmup prompt, and records whether the
# drafter allocated, what memory the load cost, and what speed the
# server reached. Then it repeats the whole ramp with `--fit on` in
# place of `-ngl 999`, to see whether automatic fitting degrades
# instead of failing.
#
# What it changes on the Mac: nothing. It starts and stops one server
# at a time and writes files under /tmp and the evidence directory.
# It does not change any setting and needs no sudo. It does not
# download: `--offline` forces the cached GGUF.
#
# Reverse direction: none needed. If the script dies, `pkill -f
# llama-server` returns the machine to idle.
#
# Owner step: none. Read this file, then run it.

set -u

CONTEXTS="8192 32768 65536 131072 262144"

MODEL_REPO="unsloth/gemma-4-12b-it-GGUF:Q4_K_XL"
ALIAS="gemma-4-12b-it"
PORT=8081

WARMUP_PROMPT="Write a Python function that parses ISO dates."

OUT="/tmp/run2/ramp"
EVIDENCE="$HOME/.local/share/choose-a-local-llm/evidence/run2-context-ramp"
TSV="$OUT/context-ramp.tsv"

LOAD_TIMEOUT=420
RECOVER_TIMEOUT=180


make_directories() {
    mkdir -p "$OUT"
    mkdir -p "$EVIDENCE"
}

write_header() {
    printf 'mode\tcontext\tload_ok\tdrafter_loaded\twired_before_mb\twired_after_mb\twired_peak_mb\tswap_used_mb\tgen_ok\ttok_s\tdraft_acceptance\tcached_tokens\tload_seconds\tnote\n' > "$TSV"
}

wired_mb() {
    local pages
    pages=$(vm_stat | awk '/Pages wired down/ {gsub("\\.","",$4); print $4}')
    echo $(( pages * 16384 / 1048576 ))
}

swap_used_mb() {
    sysctl -n vm.swapusage | awk '{gsub("M","",$6); print $6}'
}

wait_for_wired_baseline() {
    local baseline="$1"
    local margin=1500
    local waited=0
    while [ "$waited" -lt "$RECOVER_TIMEOUT" ]; do
        local now
        now=$(wired_mb)
        if [ "$now" -le $(( baseline + margin )) ]; then
            echo "  memory recovered: wired ${now} MB (baseline ${baseline} MB) after ${waited}s"
            return 0
        fi
        sleep 5
        waited=$(( waited + 5 ))
    done
    echo "  WARNING: wired stayed above baseline for ${RECOVER_TIMEOUT}s"
    return 1
}

start_server() {
    local mode="$1"
    local ctx="$2"
    local log="$3"

    local fitting_flags="-ngl 999"
    if [ "$mode" = "fit" ]; then
        fitting_flags="--fit on"
    fi

    llama-server \
        -hf "$MODEL_REPO" \
        --alias "$ALIAS" \
        --no-mmproj \
        --spec-type draft-mtp \
        --spec-draft-n-max 4 \
        --parallel 1 \
        $fitting_flags \
        -fa on \
        -c "$ctx" \
        --cache-type-k q8_0 \
        --cache-type-v q8_0 \
        --jinja \
        --offline \
        --port "$PORT" \
        > "$log" 2>&1 &

    echo $!
}

wait_for_listen() {
    local pid="$1"
    local waited=0
    while [ "$waited" -lt "$LOAD_TIMEOUT" ]; do
        if ! kill -0 "$pid" 2>/dev/null; then
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

sample_wired_peak() {
    local pid="$1"
    local peak_file="$2"
    (
        local peak=0
        while kill -0 "$pid" 2>/dev/null; do
            local now
            now=$(wired_mb)
            if [ "$now" -gt "$peak" ]; then
                peak="$now"
                echo "$peak" > "$peak_file"
            fi
            sleep 4
        done
    ) > /dev/null 2>&1 &
    echo $!
}

send_warmup() {
    local out="$1"
    curl -s -m 300 "http://127.0.0.1:$PORT/v1/chat/completions" \
        -H 'Content-Type: application/json' \
        -d "{\"model\":\"$ALIAS\",\"messages\":[{\"role\":\"user\",\"content\":\"$WARMUP_PROMPT\"}],\"max_tokens\":200,\"temperature\":0}" \
        > "$out" 2>&1
}

read_cached_tokens() {
    local file="$1"
    python3 -c "
import json,sys
try:
    d=json.load(open('$file'))
    print(d.get('usage',{}).get('prompt_tokens_details',{}).get('cached_tokens','na'))
except Exception:
    print('na')
"
}

run_one_arm() {
    local mode="$1"
    local ctx="$2"

    local tag="${mode}-${ctx}"
    local log="$OUT/server-$tag.log"
    local reply="$OUT/reply-$tag.json"
    local peak_file="$OUT/peak-$tag.txt"

    echo "=== $mode ramp, context $ctx ==="

    local wired_before
    wired_before=$(wired_mb)
    echo "  wired before: ${wired_before} MB"
    echo "0" > "$peak_file"

    local started_at
    started_at=$(date +%s)

    local pid
    pid=$(start_server "$mode" "$ctx" "$log")
    local sampler
    sampler=$(sample_wired_peak "$pid" "$peak_file")

    wait_for_listen "$pid"
    local listen_status=$?

    local load_seconds=$(( $(date +%s) - started_at ))

    local load_ok=no
    local note=""
    case "$listen_status" in
        0) load_ok=yes ;;
        1) load_ok=no ; note="process died during load" ;;
        2) load_ok=no ; note="no /health inside ${LOAD_TIMEOUT}s" ;;
    esac
    echo "  load: $load_ok after ${load_seconds}s"

    local drafter_loaded=no
    if grep -q "loading draft model" "$log"; then
        drafter_loaded=yes
    fi
    echo "  drafter loaded: $drafter_loaded"

    local gen_ok=no
    local tok_s=na
    local acceptance=na
    local cached=na
    local wired_after="$wired_before"

    if [ "$load_ok" = "yes" ]; then
        wired_after=$(wired_mb)
        send_warmup "$reply"
        if grep -q '"content"' "$reply"; then
            gen_ok=yes
        fi
        cached=$(read_cached_tokens "$reply")
        sleep 2
        tok_s=$(grep "        eval time" "$log" | tail -1 | sed -E 's/.*, +([0-9.]+) tokens per second\)$/\1/')
        acceptance=$(grep "draft acceptance" "$log" | tail -1 | sed -E 's/.*draft acceptance = ([0-9.]+) .*/\1/')
        [ -z "$tok_s" ] && tok_s=na
        [ -z "$acceptance" ] && acceptance=na
        echo "  generation: $gen_ok, ${tok_s} tok/s, draft acceptance ${acceptance}, cached_tokens ${cached}"
    else
        note="${note}; $(grep -iE 'error|failed' "$log" | tail -1 | cut -c1-120)"
        echo "  skipped generation: server never served"
    fi

    kill "$pid" 2>/dev/null
    wait "$pid" 2>/dev/null
    kill "$sampler" 2>/dev/null

    local wired_peak
    wired_peak=$(cat "$peak_file")
    local swap
    swap=$(swap_used_mb)

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$mode" "$ctx" "$load_ok" "$drafter_loaded" \
        "$wired_before" "$wired_after" "$wired_peak" "$swap" \
        "$gen_ok" "$tok_s" "$acceptance" "$cached" "$load_seconds" "$note" >> "$TSV"

    cp "$log" "$EVIDENCE/"
    wait_for_wired_baseline "$wired_before"
    echo ""
}


make_directories
write_header

echo "Context ramp starting. Wired limit: $(sysctl -n iogpu.wired_limit_mb) MB."
echo ""

for ctx in $CONTEXTS; do
    run_one_arm ngl "$ctx"
done

for ctx in $CONTEXTS; do
    run_one_arm fit "$ctx"
done

cp "$TSV" "$EVIDENCE/"
echo "Ramp done. Table: $TSV"
