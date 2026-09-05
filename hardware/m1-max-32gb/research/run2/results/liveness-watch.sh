#!/bin/bash
#
# liveness-watch.sh — research run 2, experiment for AGENT.md section E.
#
# Tells a stalled run apart from a dead server, without competing with
# the run for the GPU.
#
# The bug it is aimed at: `mlx_lm.server`'s generation thread can die
# while the process lives and `/health` answers 200 (upstream issues
# 1505, 1390, 854; the fixing PRs are unmerged). A monitor that polls
# `/health` sees a healthy server forever. A monitor that polls a real
# completion on a timer competes with the run, because these servers
# run one slot.
#
# So it probes on SUSPICION, not on a timer:
#   1. Watch the run's own output file for growth.
#   2. Only when growth has stopped for STALL_SECONDS, send ONE real
#      completion with a long timeout.
#   3. A real completion that returns means the server is alive and the
#      run is merely thinking. One that does not return means the
#      server is dead, whatever /health says.
#
# Every line it prints is an event, so it can be watched directly.
#
# What it changes on the Mac: nothing. It reads a file and sends at most
# one tiny request per stall.
#
# Reverse direction: stop it. It holds no state.
#
# Usage: liveness-watch.sh <output-file> [base-url] [model-alias]
# Environment: STALL_SECONDS (default 600), PROBE_TIMEOUT (default 300)

set -u

OUTPUT_FILE="${1:?usage: liveness-watch.sh <output-file> [base-url] [alias]}"
BASE_URL="${2:-http://127.0.0.1:8081}"
ALIAS="${3:-}"

STALL_SECONDS="${STALL_SECONDS:-600}"
PROBE_TIMEOUT="${PROBE_TIMEOUT:-300}"
POLL_SECONDS=30


output_size() {
    if [ ! -f "$OUTPUT_FILE" ]; then
        echo 0
        return
    fi
    wc -c < "$OUTPUT_FILE"
}

health_says() {
    local body
    body=$(curl -s -m 5 "$BASE_URL/health" 2>/dev/null)
    if [ -z "$body" ]; then
        echo "unreachable"
    elif echo "$body" | grep -q '"ok"'; then
        echo "ok"
    else
        echo "not-ok"
    fi
}

probe_real_completion() {
    local started
    started=$(date +%s)
    local body
    body=$(curl -s -m "$PROBE_TIMEOUT" "$BASE_URL/v1/chat/completions" \
        -H 'Content-Type: application/json' \
        -d "{\"model\":\"$ALIAS\",\"messages\":[{\"role\":\"user\",\"content\":\"ok\"}],\"max_tokens\":1,\"temperature\":0}" \
        2>/dev/null)
    local took=$(( $(date +%s) - started ))
    if echo "$body" | grep -q '"choices"'; then
        echo "alive ${took}s"
    else
        echo "no-completion ${took}s"
    fi
}


echo "watching $OUTPUT_FILE, stall threshold ${STALL_SECONDS}s, probe timeout ${PROBE_TIMEOUT}s"

previous=$(output_size)
stalled_for=0

while true; do
    sleep "$POLL_SECONDS"

    current=$(output_size)

    if [ "$current" -ne "$previous" ]; then
        stalled_for=0
        previous="$current"
        continue
    fi

    stalled_for=$(( stalled_for + POLL_SECONDS ))

    if [ "$stalled_for" -lt "$STALL_SECONDS" ]; then
        continue
    fi

    health=$(health_says)
    result=$(probe_real_completion)

    echo "STALL ${stalled_for}s: health=$health probe=$result"

    case "$result" in
        alive*)
            echo "  verdict: server alive, run is thinking. Not a failure."
            stalled_for=0
            ;;
        *)
            echo "  verdict: SERVER DEAD. /health said $health and a real"
            echo "  completion did not return. Restart and resume."
            exit 42
            ;;
    esac
done
