#!/bin/bash
#
# run-watch.sh — the one watcher of a scoring run (Mendel, EvalPlus,
# polyglot). Start it in the background beside the run. It writes the
# run's memory record and it exits the moment the server dies, so a
# coordinator that started it as a background task hears about the
# crash at once, not at the next wakeup. Bench 9 block E lost two
# mlx_lm.server Metal OOM crashes to a 15-25 minute wakeup cadence
# while /health kept answering 200. A depth sweep needs none of this:
# tools/sweeps/creep.py samples memory and liveness itself.
#
# Every poll it does three things:
#   0. When the memory interval is due, it appends one line to the
#      memory log: free RAM and the deltas of the swap and compression
#      counters from vm_stat, so a slowdown can be matched to a real
#      swap or compression event. That log is the run's memory record.
#
# Two liveness signals, never /health:
#   1. It tails the server log and matches every new line against the
#      backend death signatures (the same list as tools/sweeps/creep_*.py
#      and docs/methodology/server-lore.md). It reads whole lines only,
#      so a signature written in two pieces is still matched; a last
#      line that never gets its newline waits for the silence probe.
#   2. When the run's output file stops growing for SILENCE seconds, it
#      sends ONE real completion with a long timeout. A completion that
#      returns means the server is alive and the run is thinking.
#      Every server here holds one slot, so a probe queued behind a
#      long turn times out exactly like a probe to a dead server. So
#      one failed probe is a suspicion: if the output file grew while
#      the probe waited, the server is alive and the silence clock
#      resets. Only a second failed probe, after another full silence
#      window with no growth, calls the server dead. The same rule as
#      tools/sweeps/creep.py.
#
# It restarts nothing. It reports, the coordinator decides.
#
# Exit codes: 42 the server is dead, the reason is the last stdout line.
#             1 bad arguments. It never exits 0 on its own; stop it when
#             the run ends.
#
# What it changes on the Mac: nothing. It reads two files, appends to
# the memory log, and sends at most one tiny request per silence
# window. Reverse direction: stop it.
#
# Usage: run-watch.sh              (configuration through the environment)
#        run-watch.sh --help
#
# Environment:
#   RUNWATCH_SERVER_LOG    server log to tail. Empty: no log signal.
#   RUNWATCH_OUTPUT        the run's output file (result file, session
#                          log). Empty: no silence probe.
#   RUNWATCH_BASE_URL      server base URL, default http://127.0.0.1:8081
#   RUNWATCH_MODEL         model id for the probe request, default empty
#   RUNWATCH_SILENCE       seconds without output growth before the one
#                          probe, default 600
#   RUNWATCH_PROBE_TIMEOUT seconds to wait for the probe, default 300
#   RUNWATCH_POLL          seconds between checks, default 10
#   RUNWATCH_SIGNATURES    extended regex of death signatures, default
#                          the mlx_lm list plus the strings a crash of
#                          any backend prints. A bare `[ERROR]` is NOT
#                          in it: LM Studio logs a routine client
#                          mistake at that level ("Unexpected endpoint
#                          or method. (GET /props). Returning 200
#                          anyway"), so it would kill a healthy run.
#   RUNWATCH_MEM_LOG       memory log, default run-watch-mem.log beside
#                          this script. Scope it to the run.
#   RUNWATCH_MEM_INTERVAL  seconds between memory lines, default 20.
#                          0 turns the memory log off.
# At least one of RUNWATCH_SERVER_LOG and RUNWATCH_OUTPUT is required.
#
# Validated 2026-09-05 against a fake log that grows a death signature
# (exit 42), a fake server that stops answering through two silence
# windows (exit 42), a healthy log (stays quiet, memory lines land), and
# a fake server that hangs the probe while the output file grows (alive,
# keeps watching).

set -u
export LC_ALL=C
NEWLINE=$'\n'

SERVER_LOG="${RUNWATCH_SERVER_LOG:-}"
OUTPUT_FILE="${RUNWATCH_OUTPUT:-}"
BASE_URL="${RUNWATCH_BASE_URL:-http://127.0.0.1:8081}"
MODEL="${RUNWATCH_MODEL:-}"
SILENCE="${RUNWATCH_SILENCE:-600}"
PROBE_TIMEOUT="${RUNWATCH_PROBE_TIMEOUT:-300}"
POLL="${RUNWATCH_POLL:-10}"
MEM_LOG="${RUNWATCH_MEM_LOG:-$(dirname "$0")/run-watch-mem.log}"
MEM_INTERVAL="${RUNWATCH_MEM_INTERVAL:-20}"
PAGE_BYTES=16384
SIGNATURES="${RUNWATCH_SIGNATURES:-Insufficient Memory|Command buffer execution failed|Traceback \(most recent call last\)|Resource limit|OutOfMemory|crashed}"

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
fi

if [ -z "$SERVER_LOG" ] && [ -z "$OUTPUT_FILE" ]; then
    echo "run-watch: set RUNWATCH_SERVER_LOG or RUNWATCH_OUTPUT (see --help)" >&2
    exit 1
fi


file_size() {
    if [ ! -f "$1" ]; then
        echo 0
        return
    fi
    wc -c < "$1" | tr -d ' '
}

new_log_bytes() {
    local from="$1"
    local to="$2"
    if [ "$to" -le "$from" ]; then
        return
    fi
    tail -c +"$(( from + 1 ))" "$SERVER_LOG" | head -c "$(( to - from ))"
}

last_complete_line_end() {
    local from="$1"
    local to="$2"
    local chunk
    chunk="$(new_log_bytes "$from" "$to"; printf X)"
    chunk="${chunk%X}"
    case "$chunk" in
        *"$NEWLINE"*)
            chunk="${chunk%"$NEWLINE"*}$NEWLINE"
            echo "$(( from + ${#chunk} ))"
            ;;
        *)
            echo "$from"
            ;;
    esac
}

death_line_in_new_log_bytes() {
    new_log_bytes "$1" "$2" | grep -m1 -E "$SIGNATURES"
}

prev_swapin=0
prev_swapout=0
prev_compress=0
prev_decompress=0
mem_first=1
mem_last=0

write_memory_line() {
    local s free swapin swapout compress decompress free_mb
    s=$(vm_stat 2>/dev/null)
    if [ -z "$s" ]; then
        if [ "$mem_first" = "1" ]; then
            echo "vm_stat not found: no memory lines (this method reads the macOS counters)"
            mem_first=0
        fi
        return
    fi
    free=$(echo "$s" | awk '/Pages free/ {gsub("\\.",""); print $3}')
    swapin=$(echo "$s" | awk '/Swapins/ {gsub("\\.",""); print $2}')
    swapout=$(echo "$s" | awk '/Swapouts/ {gsub("\\.",""); print $2}')
    compress=$(echo "$s" | awk '/Compressions/ {gsub("\\.",""); print $2}')
    decompress=$(echo "$s" | awk '/Decompressions/ {gsub("\\.",""); print $2}')
    free_mb=$(( free * PAGE_BYTES / 1024 / 1024 ))
    if [ "$mem_first" = "1" ]; then
        d_swapin=0; d_swapout=0; d_compress=0; d_decompress=0
        mem_first=0
    else
        d_swapin=$(( swapin - prev_swapin ))
        d_swapout=$(( swapout - prev_swapout ))
        d_compress=$(( compress - prev_compress ))
        d_decompress=$(( decompress - prev_decompress ))
    fi
    prev_swapin=$swapin; prev_swapout=$swapout; prev_compress=$compress; prev_decompress=$decompress
    echo "$(date '+%H:%M:%S') free_mb=$free_mb d_swapin=$d_swapin d_swapout=$d_swapout d_compress=$d_compress d_decompress=$d_decompress" >> "$MEM_LOG"
}

memory_line_when_due() {
    if [ "$MEM_INTERVAL" -le 0 ]; then
        return
    fi
    local now
    now=$(date +%s)
    if [ $(( now - mem_last )) -lt "$MEM_INTERVAL" ]; then
        return
    fi
    mem_last=$now
    write_memory_line
}

probe_real_completion() {
    local body
    body=$(curl -s -m "$PROBE_TIMEOUT" "$BASE_URL/v1/chat/completions" \
        -H 'Content-Type: application/json' \
        -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"ok\"}],\"max_tokens\":1,\"temperature\":0}" \
        2>/dev/null)
    echo "$body" | grep -q '"choices"'
}


echo "run-watch: log=${SERVER_LOG:-none} output=${OUTPUT_FILE:-none} url=$BASE_URL silence=${SILENCE}s probe_timeout=${PROBE_TIMEOUT}s poll=${POLL}s mem_log=$MEM_LOG mem_interval=${MEM_INTERVAL}s"
memory_line_when_due

log_seen=0
if [ -n "$SERVER_LOG" ]; then
    log_seen=$(file_size "$SERVER_LOG")
fi
output_seen=0
if [ -n "$OUTPUT_FILE" ]; then
    output_seen=$(file_size "$OUTPUT_FILE")
fi
silent_for=0
failed_probes=0

while true; do
    sleep "$POLL"
    memory_line_when_due

    if [ -n "$SERVER_LOG" ]; then
        log_now=$(file_size "$SERVER_LOG")
        if [ "$log_now" -lt "$log_seen" ]; then
            echo "server log shrank (rotated or truncated); reading from its start"
            log_seen=0
        fi
        log_end=$(last_complete_line_end "$log_seen" "$log_now")
        line=$(death_line_in_new_log_bytes "$log_seen" "$log_end")
        if [ -n "$line" ]; then
            echo "SERVER DEAD: death signature in $SERVER_LOG: ${line:0:200}"
            exit 42
        fi
        log_seen="$log_end"
    fi

    if [ -z "$OUTPUT_FILE" ]; then
        continue
    fi

    output_now=$(file_size "$OUTPUT_FILE")
    if [ "$output_now" -ne "$output_seen" ]; then
        output_seen="$output_now"
        silent_for=0
        failed_probes=0
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
        failed_probes=0
        continue
    fi
    silent_for=0
    output_now=$(file_size "$OUTPUT_FILE")
    if [ "$output_now" -ne "$output_seen" ]; then
        output_seen="$output_now"
        failed_probes=0
        echo "  probe did not return, but the output grew while it waited: server alive, probe dropped"
        continue
    fi
    failed_probes=$(( failed_probes + 1 ))
    if [ "$failed_probes" -lt 2 ]; then
        echo "  probe 1 of 2 did not return within ${PROBE_TIMEOUT}s. A probe queued behind a live turn fails the same way; waiting ${SILENCE}s more"
        continue
    fi
    echo "SERVER DEAD: two probes did not return, each after ${SILENCE}s without output growth on $OUTPUT_FILE"
    exit 42
done
