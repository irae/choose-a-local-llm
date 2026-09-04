#!/bin/bash
#
# h4-memory-recovery.sh — do the two memory meters disagree after a big
# model server dies?
#
# Run 7 guessed they might (its hypothesis 4) and never tested it. The
# guess: vm_stat reports memory free before the GPU has released it, so
# a pre-run check reads recovery that has not happened, lets the next
# server start, and that server dies inside Metal.
#
# The two meters:
#   vm_stat                  whole machine, free and wired pages
#   vmmap --summary <pid>    one process, its IOAccelerator region is
#                            the GPU-visible memory it holds
#
# Method: load a large model, warm it so the memory is really committed,
# read both meters, kill the server, then read both every few seconds
# for three minutes. If free jumps while IOAccelerator drains slowly,
# hypothesis 4 holds and the pre-run gate reads the wrong meter.
#
# The serving command is the vetted one from
# docs/setups/m1-max-32gb/benchmarks/bonsai-27b.md — bounded prompt
# cache, no MTP, no -ngl override.
#
# Usage: h4-memory-recovery.sh

set -u

OUT="$HOME/.local/share/choose-a-local-llm/evidence/h4-memory-recovery"
PORT=8081
SAMPLES=36
INTERVAL=5

mkdir -p "$OUT"
LOG="$OUT/samples.tsv"


say() {
    echo "[$(date +%H:%M:%S)] $*"
}


free_mb() {
    vm_stat | awk '/Pages free/ {gsub(/[ .]/,"",$3); print int($3*16384/1048576)}'
}


wired_mb() {
    vm_stat | awk '/Pages wired down/ {gsub(/[ .]/,"",$4); print int($4*16384/1048576)}'
}


swap_mb() {
    sysctl -n vm.swapusage | awk '{gsub(/M/,"",$6); print $6}'
}


# Returns the RESIDENT size of the process's IOAccelerator regions, in MB.
# The raw vmmap line is appended to $OUT/vmmap-raw.txt so a wrong parse is
# visible instead of silently returning a plausible number. The first
# attempt at this test read the wrong column and reported 1 MB for an
# 8 GB model, which looked like data and was not.
iogpu_mb() {
    local pid="$1"

    if [ -z "$pid" ] || ! kill -0 "$pid" 2>/dev/null; then
        echo 0
        return
    fi

    local line
    line=$(vmmap --summary "$pid" 2>/dev/null | grep -i "IOAccelerator" | head -1)

    if [ -z "$line" ]; then
        echo "no-IOAccelerator-line pid=$pid" >> "$OUT/vmmap-raw.txt"
        echo 0
        return
    fi

    echo "$line" >> "$OUT/vmmap-raw.txt"

    echo "$line" | awk '{
        n = 0
        for (i = 1; i <= NF; i++) {
            if ($i ~ /^[0-9.]+[KMG]?$/) { sizes[++n] = $i }
        }
        v = sizes[2]
        if (v ~ /G/) { gsub(/G/, "", v); printf "%d", v * 1024 }
        else if (v ~ /M/) { gsub(/M/, "", v); printf "%d", v }
        else if (v ~ /K/) { gsub(/K/, "", v); printf "%d", v / 1024 }
        else { printf "%d", v }
    }'
}


sample() {
    local label="$1"
    local pid="$2"
    printf "%s\t%s\t%s\t%s\t%s\t%s\n" \
        "$(date +%H:%M:%S)" "$label" "$(free_mb)" "$(wired_mb)" \
        "$(iogpu_mb "$pid")" "$(swap_mb)" | tee -a "$LOG"
}


say "stopping anything on the GPU"
"$HOME/.cache/lm-studio/bin/lms" unload --all > /dev/null 2>&1
osascript -e 'quit app "LM Studio"' > /dev/null 2>&1
pkill -f "mlx_lm.server" 2>/dev/null
pkill -f "llama-server" 2>/dev/null
sleep 10

printf "time\tlabel\tfree_mb\twired_mb\tiogpu_mb\tswap_mb\n" > "$LOG"
sample "idle-before" ""

say "starting the Bonsai on the vetted command"
mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit \
    --prompt-cache-size 2 --port "$PORT" > "$OUT/server.log" 2>&1 &

waited=0
while [ "$waited" -lt 300 ]; do
    if curl -s -m 3 "http://127.0.0.1:$PORT/v1/models" > /dev/null 2>&1; then
        break
    fi
    sleep 10
    waited=$(( waited + 10 ))
done

SERVER_PID=$(pgrep -f "mlx_lm.server" | head -1)

if [ -z "$SERVER_PID" ]; then
    say "server never started"
    tail -5 "$OUT/server.log"
    exit 1
fi

say "server pid $SERVER_PID, warming it so the memory is committed"
curl -s -m 300 "http://127.0.0.1:$PORT/v1/chat/completions" \
    -H 'Content-Type: application/json' \
    -d '{"model":"prism-ml/Ternary-Bonsai-27B-mlx-2bit","messages":[{"role":"user","content":"Count to twenty."}],"max_tokens":200}' \
    > "$OUT/warmup.json" 2>&1

sample "loaded-warm" "$SERVER_PID"

say "killing the server"
kill "$SERVER_PID" 2>/dev/null

index=0
while [ "$index" -lt "$SAMPLES" ]; do
    sleep "$INTERVAL"
    sample "after-kill-$(( (index + 1) * INTERVAL ))s" "$SERVER_PID"
    index=$(( index + 1 ))
done

say "done, samples in $LOG"
