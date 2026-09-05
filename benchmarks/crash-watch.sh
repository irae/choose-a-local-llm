#!/bin/bash
#
# crash-watch.sh — live crash watcher for a scoring run (Mendel,
# EvalPlus, polyglot). Start it in the background beside the run. It
# exits the moment the server dies, so a coordinator that started it as
# a background task hears about the crash at once, not at the next
# wakeup. Bench 9 block E lost two mlx_lm.server Metal OOM crashes to a
# 15-25 minute wakeup cadence while /health kept answering 200.
#
# Two signals, never /health:
#   1. It tails the server log and matches every new line against the
#      backend death signatures (the same list as tools/sweeps/creep_*.py
#      and docs/methodology/server-lore.md).
#   2. When the run's output file stops growing for SILENCE seconds, it
#      sends ONE real completion with a long timeout. A completion that
#      returns means the server is alive and the run is thinking. One
#      that does not return means the server is dead.
#
# It restarts nothing. It reports, the coordinator decides.
#
# Exit codes: 42 the server is dead, the reason is the last stdout line.
#             1 bad arguments. It never exits 0 on its own; stop it when
#             the run ends.
#
# What it changes on the Mac: nothing. It reads two files and sends at
# most one tiny request per silence. Reverse direction: stop it.
#
# Usage: crash-watch.sh            (configuration through the environment)
#        crash-watch.sh --help
#
# Environment:
#   CRASHWATCH_SERVER_LOG   server log to tail. Empty: no log signal.
#   CRASHWATCH_OUTPUT       the run's output file (result file, session
#                           log). Empty: no silence probe.
#   CRASHWATCH_BASE_URL     server base URL, default http://127.0.0.1:8081
#   CRASHWATCH_MODEL        model id for the probe request, default empty
#   CRASHWATCH_SILENCE      seconds without output growth before the one
#                           probe, default 600
#   CRASHWATCH_PROBE_TIMEOUT seconds to wait for the probe, default 300
#   CRASHWATCH_POLL         seconds between checks, default 10
#   CRASHWATCH_SIGNATURES   extended regex of death signatures, default
#                           the union of the mlx_lm and LM Studio lists
# At least one of CRASHWATCH_SERVER_LOG and CRASHWATCH_OUTPUT is required.
#
# Validated 2026-09-05 against a fake log that grows a death signature
# and a fake server that stops answering (both exit 42 with the reason)
# and a healthy log (stays quiet).

set -u

SERVER_LOG="${CRASHWATCH_SERVER_LOG:-}"
OUTPUT_FILE="${CRASHWATCH_OUTPUT:-}"
BASE_URL="${CRASHWATCH_BASE_URL:-http://127.0.0.1:8081}"
MODEL="${CRASHWATCH_MODEL:-}"
SILENCE="${CRASHWATCH_SILENCE:-600}"
PROBE_TIMEOUT="${CRASHWATCH_PROBE_TIMEOUT:-300}"
POLL="${CRASHWATCH_POLL:-10}"
SIGNATURES="${CRASHWATCH_SIGNATURES:-Insufficient Memory|Command buffer execution failed|Traceback \(most recent call last\)|Resource limit|OutOfMemory|\[ERROR\]|crashed}"

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
fi

if [ -z "$SERVER_LOG" ] && [ -z "$OUTPUT_FILE" ]; then
    echo "crash-watch: set CRASHWATCH_SERVER_LOG or CRASHWATCH_OUTPUT (see --help)" >&2
    exit 1
fi


file_size() {
    if [ ! -f "$1" ]; then
        echo 0
        return
    fi
    wc -c < "$1" | tr -d ' '
}

death_line_in_new_log_bytes() {
    local from="$1"
    local to="$2"
    if [ "$to" -le "$from" ]; then
        return 1
    fi
    tail -c +"$(( from + 1 ))" "$SERVER_LOG" | head -c "$(( to - from ))" \
        | grep -m1 -E "$SIGNATURES"
}

probe_real_completion() {
    local body
    body=$(curl -s -m "$PROBE_TIMEOUT" "$BASE_URL/v1/chat/completions" \
        -H 'Content-Type: application/json' \
        -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"ok\"}],\"max_tokens\":1,\"temperature\":0}" \
        2>/dev/null)
    echo "$body" | grep -q '"choices"'
}


echo "crash-watch: log=${SERVER_LOG:-none} output=${OUTPUT_FILE:-none} url=$BASE_URL silence=${SILENCE}s probe_timeout=${PROBE_TIMEOUT}s poll=${POLL}s"

log_seen=0
if [ -n "$SERVER_LOG" ]; then
    log_seen=$(file_size "$SERVER_LOG")
fi
output_seen=0
if [ -n "$OUTPUT_FILE" ]; then
    output_seen=$(file_size "$OUTPUT_FILE")
fi
silent_for=0

while true; do
    sleep "$POLL"

    if [ -n "$SERVER_LOG" ]; then
        log_now=$(file_size "$SERVER_LOG")
        if [ "$log_now" -lt "$log_seen" ]; then
            echo "server log shrank (rotated or truncated); reading from its start"
            log_seen=0
        fi
        line=$(death_line_in_new_log_bytes "$log_seen" "$log_now")
        if [ -n "$line" ]; then
            echo "SERVER DEAD: death signature in $SERVER_LOG: ${line:0:200}"
            exit 42
        fi
        log_seen="$log_now"
    fi

    if [ -z "$OUTPUT_FILE" ]; then
        continue
    fi

    output_now=$(file_size "$OUTPUT_FILE")
    if [ "$output_now" -ne "$output_seen" ]; then
        output_seen="$output_now"
        silent_for=0
        continue
    fi

    silent_for=$(( silent_for + POLL ))
    if [ "$silent_for" -lt "$SILENCE" ]; then
        continue
    fi

    echo "silence ${silent_for}s on $OUTPUT_FILE: probing one real completion"
    if probe_real_completion; then
        echo "  probe answered: server alive, the run is thinking"
        silent_for=0
        continue
    fi
    echo "SERVER DEAD: no output for ${silent_for}s and a real completion did not return within ${PROBE_TIMEOUT}s"
    exit 42
done
