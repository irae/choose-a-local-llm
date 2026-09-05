#!/bin/bash
# Tests for benchmarks/run-watch.sh. Real server logs and real vm_stat
# output, a fake completion server, and a fake vm_stat on PATH.

set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$HERE")"
WATCH="$ROOT/benchmarks/run-watch.sh"
FIXTURES="$HERE/fixtures"
PASS=0
FAIL=0

ok() {
    PASS=$(( PASS + 1 ))
    echo "  ok   $1"
}

bad() {
    FAIL=$(( FAIL + 1 ))
    echo "  FAIL $1"
}

assert_contains() {
    case "$2" in
        *"$3"*) ok "$1" ;;
        *) bad "$1"; echo "        wanted: $3"; echo "        got: $(echo "$2" | tr '\n' '|' | cut -c1-300)" ;;
    esac
}

assert_missing() {
    case "$2" in
        *"$3"*) bad "$1"; echo "        did not want: $3" ;;
        *) ok "$1" ;;
    esac
}

assert_equal() {
    if [ "$2" = "$3" ]; then
        ok "$1"
    else
        bad "$1"
        echo "        wanted: $3"
        echo "        got: $2"
    fi
}

new_case() {
    CASE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/run-watch-test.XXXXXX")
    OUT_LOG="$CASE_DIR/watch-out.txt"
    SERVER_LOG="$CASE_DIR/server.log"
    OUTPUT_FILE="$CASE_DIR/run-output.txt"
    MEM_LOG="$CASE_DIR/mem.log"
    : > "$SERVER_LOG"
    : > "$OUTPUT_FILE"
}

# Starts run-watch in the background. WATCH_PID and OUT_LOG are the handles.
start_watch() {
    RUNWATCH_SERVER_LOG="${SERVER_LOG}" \
    RUNWATCH_OUTPUT="${WATCH_OUTPUT-}" \
    RUNWATCH_BASE_URL="${WATCH_URL:-http://127.0.0.1:1}" \
    RUNWATCH_SILENCE="${WATCH_SILENCE:-2}" \
    RUNWATCH_PROBE_TIMEOUT="${WATCH_PROBE_TIMEOUT:-2}" \
    RUNWATCH_POLL=1 \
    RUNWATCH_MEM_LOG="$MEM_LOG" \
    RUNWATCH_MEM_INTERVAL="${WATCH_MEM_INTERVAL:-0}" \
        bash "$WATCH" > "$OUT_LOG" 2>&1 &
    WATCH_PID=$!
}

# Waits up to $1 seconds for the watcher to exit. Sets RESULT to its exit
# code, or to "running" when it is still alive. Never call it in a
# subshell: only this shell can reap its own background job.
wait_watch() {
    local waited=0
    while [ "$waited" -lt "$1" ]; do
        if ! kill -0 "$WATCH_PID" 2>/dev/null; then
            wait "$WATCH_PID"
            RESULT=$?
            return
        fi
        sleep 1
        waited=$(( waited + 1 ))
    done
    kill "$WATCH_PID" 2>/dev/null
    wait "$WATCH_PID" 2>/dev/null
    RESULT=running
}

start_fake_server() {
    PORT=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
    python3 "$HERE/helpers/fake-server.py" "$PORT" "$1" "${2:-3600}" &
    SERVER_PID=$!
    WATCH_URL="http://127.0.0.1:$PORT"
    local waited=0
    while [ "$waited" -lt 50 ]; do
        if python3 -c "
import socket, sys
s = socket.socket()
s.settimeout(0.2)
sys.exit(0 if s.connect_ex(('127.0.0.1', $PORT)) == 0 else 1)
"; then
            return
        fi
        sleep 0.1
        waited=$(( waited + 1 ))
    done
}

stop_fake_server() {
    kill "$SERVER_PID" 2>/dev/null
    wait "$SERVER_PID" 2>/dev/null
    unset WATCH_URL
}


test_help_exits_zero() {
    local out status
    out=$(bash "$WATCH" --help)
    status=$?
    assert_equal "help exits 0" "$status" "0"
    assert_contains "help names the tool" "$out" "run-watch.sh"
    assert_contains "help lists the environment" "$out" "RUNWATCH_SILENCE"
    assert_missing "help strips the comment marks" "$out" "# RUNWATCH_SILENCE"
}

test_no_inputs_exits_one() {
    local out status
    out=$(RUNWATCH_SERVER_LOG= RUNWATCH_OUTPUT= bash "$WATCH" 2>&1)
    status=$?
    assert_equal "no inputs exits 1" "$status" "1"
    assert_contains "no inputs says what to set" "$out" "RUNWATCH_SERVER_LOG"
}

test_old_signature_does_not_fire() {
    new_case
    cat "$FIXTURES/server-llama-oom.log" > "$SERVER_LOG"
    start_watch
    sleep 4
    wait_watch 1
    assert_equal "a signature already in the log does not fire" "$RESULT" "running"
    assert_missing "and nothing is reported dead" "$(cat "$OUT_LOG")" "SERVER DEAD"
    rm -rf "$CASE_DIR"
}

test_new_llama_signature_fires() {
    new_case
    head -8 "$FIXTURES/server-llama-oom.log" > "$SERVER_LOG"
    start_watch
    sleep 2
    cat "$FIXTURES/server-llama-oom.log" >> "$SERVER_LOG"
    wait_watch 8
    assert_equal "a new llama-server OOM line exits 42" "$RESULT" "42"
    assert_contains "and names the signature" "$(cat "$OUT_LOG")" "Insufficient Memory"
    rm -rf "$CASE_DIR"
}

test_new_mlx_signature_fires() {
    new_case
    start_watch
    sleep 2
    cat "$FIXTURES/server-mlx-metal-oom.log" >> "$SERVER_LOG"
    wait_watch 8
    assert_equal "an mlx_lm Metal OOM traceback exits 42" "$RESULT" "42"
    assert_contains "and names the signature" "$(cat "$OUT_LOG")" "SERVER DEAD"
    rm -rf "$CASE_DIR"
}

test_healthy_llama_log_stays_quiet() {
    new_case
    start_watch
    sleep 2
    cat "$FIXTURES/server-llama-healthy.log" >> "$SERVER_LOG"
    wait_watch 4
    assert_equal "a healthy llama-server log keeps the watcher alive" "$RESULT" "running"
    assert_missing "and reports nothing" "$(cat "$OUT_LOG")" "SERVER DEAD"
    rm -rf "$CASE_DIR"
}

test_healthy_lmstudio_log_stays_quiet() {
    new_case
    start_watch
    sleep 2
    cat "$FIXTURES/server-lmstudio-healthy.log" >> "$SERVER_LOG"
    wait_watch 4
    assert_equal "a healthy LM Studio log keeps the watcher alive" "$RESULT" "running"
    assert_missing "and reports nothing" "$(cat "$OUT_LOG")" "SERVER DEAD"
    rm -rf "$CASE_DIR"
}

test_truncated_log_is_read_from_its_start() {
    new_case
    cat "$FIXTURES/server-llama-healthy.log" > "$SERVER_LOG"
    start_watch
    sleep 2
    head -8 "$FIXTURES/server-llama-oom.log" > "$SERVER_LOG"
    sleep 2
    cat "$FIXTURES/server-llama-oom.log" > "$SERVER_LOG"
    wait_watch 8
    assert_contains "a shrinking log is reported" "$(cat "$OUT_LOG")" "server log shrank"
    assert_equal "and the signature in the new file exits 42" "$RESULT" "42"
    rm -rf "$CASE_DIR"
}

test_signature_split_across_two_polls() {
    new_case
    start_watch
    sleep 2
    printf 'RuntimeError: [METAL] Command buffer exec' >> "$SERVER_LOG"
    sleep 3
    printf 'ution failed: no memory\n' >> "$SERVER_LOG"
    wait_watch 8
    assert_equal "a signature written in two pieces still exits 42" "$RESULT" "42"
    rm -rf "$CASE_DIR"
}

test_silence_with_a_live_server_is_not_death() {
    new_case
    WATCH_OUTPUT="$OUTPUT_FILE"
    start_fake_server answer
    start_watch
    wait_watch 8
    stop_fake_server
    assert_contains "a silent output file starts one probe" "$(cat "$OUT_LOG")" "probing one real completion"
    assert_contains "an answered probe means alive" "$(cat "$OUT_LOG")" "probe answered"
    assert_equal "and the watcher keeps watching" "$RESULT" "running"
    unset WATCH_OUTPUT
    rm -rf "$CASE_DIR"
}

test_two_failed_probes_mean_death() {
    new_case
    WATCH_OUTPUT="$OUTPUT_FILE"
    start_watch
    wait_watch 20
    local out
    out=$(cat "$OUT_LOG")
    assert_contains "one failed probe is only a suspicion" "$out" "probe 1 of 2"
    assert_equal "two failed probes exit 42" "$RESULT" "42"
    assert_contains "and the reason names the two probes" "$out" "two probes did not return"
    unset WATCH_OUTPUT
    rm -rf "$CASE_DIR"
}

test_growth_during_a_probe_means_alive() {
    new_case
    WATCH_OUTPUT="$OUTPUT_FILE"
    WATCH_PROBE_TIMEOUT=3
    start_fake_server hang 30
    start_watch
    # Wait for the probe to start, then let the run write while it hangs.
    local waited=0
    while [ "$waited" -lt 20 ]; do
        if grep -q "probing one real completion" "$OUT_LOG" 2>/dev/null; then
            break
        fi
        sleep 1
        waited=$(( waited + 1 ))
    done
    echo "the run wrote a result" >> "$OUTPUT_FILE"
    wait_watch 12
    stop_fake_server
    assert_contains "growth during a probe means alive" "$(cat "$OUT_LOG")" "output grew while it waited"
    assert_equal "and the watcher keeps watching" "$RESULT" "running"
    unset WATCH_OUTPUT
    unset WATCH_PROBE_TIMEOUT
    rm -rf "$CASE_DIR"
}

test_memory_lines_land_at_the_interval() {
    new_case
    WATCH_MEM_INTERVAL=1
    local bin="$CASE_DIR/bin"
    mkdir -p "$bin"
    cp "$HERE/helpers/fake-vm_stat" "$bin/vm_stat"
    export PATH="$bin:$PATH"
    export FAKE_VM_STAT_DIR="$FIXTURES"
    export FAKE_VM_STAT_COUNT="$CASE_DIR/vm_stat.count"
    start_watch
    sleep 4
    wait_watch 1
    export PATH="${PATH#"$bin:"}"
    local lines first second
    lines=$(wc -l < "$MEM_LOG" | tr -d ' ')
    if [ "${lines:-0}" -ge 2 ]; then
        ok "the memory log gets one line per interval"
    else
        bad "the memory log gets one line per interval"
        echo "        got $lines lines"
    fi
    first=$(sed -n 1p "$MEM_LOG")
    second=$(sed -n 2p "$MEM_LOG")
    # vm_stat-1.txt: 1383559 free pages of 16384 bytes = 21618 MB.
    assert_contains "free RAM comes from the real vm_stat page count" "$first" "free_mb=21618"
    assert_contains "the first line has no deltas" "$first" "d_swapin=0"
    # vm_stat-2.txt: swapins 64228 against 64200 in sample 1.
    assert_contains "the second line has the real swap delta" "$second" "d_swapin=28"
    assert_contains "and the compression delta" "$second" "d_compress=0"
    unset WATCH_MEM_INTERVAL FAKE_VM_STAT_DIR FAKE_VM_STAT_COUNT
    rm -rf "$CASE_DIR"
}

test_memory_log_off_writes_nothing() {
    new_case
    WATCH_MEM_INTERVAL=0
    start_watch
    sleep 3
    wait_watch 1
    if [ -e "$MEM_LOG" ]; then
        bad "interval 0 writes no memory log"
    else
        ok "interval 0 writes no memory log"
    fi
    unset WATCH_MEM_INTERVAL
    rm -rf "$CASE_DIR"
}


echo "run-watch.sh"
test_help_exits_zero
test_no_inputs_exits_one
test_old_signature_does_not_fire
test_new_llama_signature_fires
test_new_mlx_signature_fires
test_healthy_llama_log_stays_quiet
test_healthy_lmstudio_log_stays_quiet
test_truncated_log_is_read_from_its_start
test_signature_split_across_two_polls
test_silence_with_a_live_server_is_not_death
test_two_failed_probes_mean_death
test_growth_during_a_probe_means_alive
test_memory_lines_land_at_the_interval
test_memory_log_off_writes_nothing

echo "run-watch.sh: $PASS passed, $FAIL failed"
[ "$FAIL" = "0" ]
