#!/bin/bash
# Tests for benchmarks/mendel-smoke.sh, through SMOKE_MENDEL_SESSION.
# The pi run needs a model and a GPU, so it stays out; these tests cover
# the counters, the loop verdict, the git columns and the pass or fail
# rule. The session logs are real Mendel logs, trimmed.

set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$HERE")"
SMOKE="$ROOT/benchmarks/mendel-smoke.sh"
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
        *) bad "$1"; echo "        wanted: $3"; echo "        got: $2" ;;
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

# Runs the smoke on a session log and leaves its SMOKE-MENDEL line in LINE.
smoke_on() {
    CASE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/mendel-smoke-test.XXXXXX")
    OUT_TEXT=$(SMOKE_MENDEL_OUT="$CASE_DIR" SMOKE_MENDEL_SESSION="$1" \
        SMOKE_MENDEL_CAP="${CASE_CAP:-1500}" \
        bash "$SMOKE" test-model low 2>&1)
    LINE=$(echo "$OUT_TEXT" | grep '^SMOKE-MENDEL' || true)
}

# Builds a fixture repository that looks like a finished task: a base
# commit plus the model's own commit, tree clean.
committed_fixture() {
    local work="$1/fixture"
    mkdir -p "$work"
    git -C "$work" init -q
    echo base > "$work/a.txt"
    git -C "$work" add -A
    git -C "$work" -c user.name=t -c user.email=t@localhost commit -q -m base
    echo done > "$work/a.txt"
    git -C "$work" add -A
    git -C "$work" -c user.name=t -c user.email=t@localhost commit -q -m work
}

field() {
    echo "$1" | tr ' ' '\n' | grep "^$2=" | cut -d= -f2-
}


test_help_exits_zero() {
    local out status
    out=$(bash "$SMOKE" --help)
    status=$?
    assert_equal "help exits 0" "$status" "0"
    assert_contains "help names the tool" "$out" "mendel-smoke.sh"
    assert_contains "help lists the verification path" "$out" "SMOKE_MENDEL_SESSION"
    assert_contains "help states the reading rule" "$out" "THE READING RULE"
}

test_missing_arguments_refuse() {
    local out status
    out=$(bash "$SMOKE" 2>&1)
    status=$?
    if [ "$status" = "0" ]; then
        bad "no arguments refuses"
    else
        ok "no arguments refuses"
    fi
    assert_contains "and prints the usage" "$out" "usage: mendel-smoke.sh"
    out=$(bash "$SMOKE" only-a-model 2>&1)
    assert_contains "one argument refuses too" "$out" "usage: mendel-smoke.sh"
}

test_counters_on_a_looped_session() {
    smoke_on "$FIXTURES/session-loop.jsonl"
    assert_contains "a looped log counts every tool call" "$LINE" "calls=61"
    assert_contains "and one distinct call" "$LINE" "distinct=1"
    assert_contains "and the whole run is one repeat" "$LINE" "longest_run=61"
    assert_contains "the loop check reports the ratio" "$LINE" "loop=LOOP:0.02"
    assert_contains "the stop reason comes from the log" "$LINE" "end=toolUse"
    assert_contains "a loop fails" "$LINE" "verdict=fail"
    rm -rf "$CASE_DIR"
}

test_counters_on_a_healthy_session() {
    smoke_on "$FIXTURES/session-healthy.jsonl"
    assert_contains "a healthy log counts its tool calls" "$LINE" "calls=24"
    assert_contains "and they are all different" "$LINE" "distinct=24"
    assert_contains "and no call repeats" "$LINE" "longest_run=1"
    assert_contains "the loop check passes" "$LINE" "loop=ok:0.47"
    assert_contains "the stop reason is the model's own" "$LINE" "end=stop"
    assert_contains "the wall time comes from the log stamps" "$LINE" "wall_s=252"
    rm -rf "$CASE_DIR"
}

test_the_session_path_runs_no_pi() {
    smoke_on "$FIXTURES/session-healthy.jsonl"
    assert_contains "the session path says it reads the log" "$OUT_TEXT" "no pi run"
    assert_missing "and builds no fixture" "$OUT_TEXT" "fixture ready"
    assert_contains "so the git columns are n/a" "$LINE" "commits=n/a"
    assert_contains "and the clean column too" "$LINE" "clean=n/a"
    rm -rf "$CASE_DIR"
}

test_a_missing_session_log_is_a_fail() {
    smoke_on "$FIXTURES/there-is-no-such-log.jsonl"
    assert_contains "no log gives the nolog reason" "$LINE" "end=nolog"
    assert_contains "and no calls" "$LINE" "calls=0"
    assert_contains "and fails" "$LINE" "verdict=fail"
    rm -rf "$CASE_DIR"
}

test_a_log_with_no_assistant_message_is_a_fail() {
    CASE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/mendel-smoke-test.XXXXXX")
    printf '{"type":"session","id":"x"}\nnot json at all\n' > "$CASE_DIR/empty.jsonl"
    OUT_TEXT=$(SMOKE_MENDEL_OUT="$CASE_DIR" SMOKE_MENDEL_SESSION="$CASE_DIR/empty.jsonl" \
        bash "$SMOKE" test-model low 2>&1)
    LINE=$(echo "$OUT_TEXT" | grep '^SMOKE-MENDEL' || true)
    assert_contains "a log with no assistant message counts none" "$LINE" "calls=0"
    assert_contains "and has no stop reason" "$LINE" "end=none"
    assert_contains "and fails" "$LINE" "verdict=fail"
    rm -rf "$CASE_DIR"
}

test_a_committed_clean_tree_passes() {
    CASE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/mendel-smoke-test.XXXXXX")
    committed_fixture "$CASE_DIR"
    OUT_TEXT=$(SMOKE_MENDEL_OUT="$CASE_DIR" \
        SMOKE_MENDEL_SESSION="$FIXTURES/session-healthy.jsonl" \
        bash "$SMOKE" test-model low 2>&1)
    LINE=$(echo "$OUT_TEXT" | grep '^SMOKE-MENDEL' || true)
    assert_contains "the model's commit is counted" "$LINE" "commits=1"
    assert_contains "the tree is clean" "$LINE" "clean=yes"
    assert_contains "committed work with no loop passes" "$LINE" "verdict=pass"
    rm -rf "$CASE_DIR"
}

test_a_loop_fails_a_committed_tree() {
    CASE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/mendel-smoke-test.XXXXXX")
    committed_fixture "$CASE_DIR"
    OUT_TEXT=$(SMOKE_MENDEL_OUT="$CASE_DIR" \
        SMOKE_MENDEL_SESSION="$FIXTURES/session-loop.jsonl" \
        bash "$SMOKE" test-model low 2>&1)
    LINE=$(echo "$OUT_TEXT" | grep '^SMOKE-MENDEL' || true)
    assert_contains "the commit still counts" "$LINE" "commits=1"
    assert_contains "but a repetition loop fails the smoke" "$LINE" "verdict=fail"
    rm -rf "$CASE_DIR"
}

test_a_dirty_tree_fails() {
    CASE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/mendel-smoke-test.XXXXXX")
    committed_fixture "$CASE_DIR"
    echo "left behind" > "$CASE_DIR/fixture/b.txt"
    OUT_TEXT=$(SMOKE_MENDEL_OUT="$CASE_DIR" \
        SMOKE_MENDEL_SESSION="$FIXTURES/session-healthy.jsonl" \
        bash "$SMOKE" test-model low 2>&1)
    LINE=$(echo "$OUT_TEXT" | grep '^SMOKE-MENDEL' || true)
    assert_contains "an untracked file makes the tree dirty" "$LINE" "clean=no"
    assert_contains "and a dirty tree fails" "$LINE" "verdict=fail"
    rm -rf "$CASE_DIR"
}

test_no_commit_of_its_own_fails() {
    CASE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/mendel-smoke-test.XXXXXX")
    mkdir -p "$CASE_DIR/fixture"
    git -C "$CASE_DIR/fixture" init -q
    echo base > "$CASE_DIR/fixture/a.txt"
    git -C "$CASE_DIR/fixture" add -A
    git -C "$CASE_DIR/fixture" -c user.name=t -c user.email=t@localhost commit -q -m base
    OUT_TEXT=$(SMOKE_MENDEL_OUT="$CASE_DIR" \
        SMOKE_MENDEL_SESSION="$FIXTURES/session-healthy.jsonl" \
        bash "$SMOKE" test-model low 2>&1)
    LINE=$(echo "$OUT_TEXT" | grep '^SMOKE-MENDEL' || true)
    assert_contains "only the base commit counts as zero" "$LINE" "commits=0"
    assert_contains "and no commit fails" "$LINE" "verdict=fail"
    rm -rf "$CASE_DIR"
}

test_the_cap_fails_the_smoke() {
    CASE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/mendel-smoke-test.XXXXXX")
    committed_fixture "$CASE_DIR"
    OUT_TEXT=$(SMOKE_MENDEL_OUT="$CASE_DIR" SMOKE_MENDEL_CAP=100 \
        SMOKE_MENDEL_SESSION="$FIXTURES/session-healthy.jsonl" \
        bash "$SMOKE" test-model low 2>&1)
    LINE=$(echo "$OUT_TEXT" | grep '^SMOKE-MENDEL' || true)
    assert_contains "a run at or past the cap fails" "$LINE" "verdict=fail"
    rm -rf "$CASE_DIR"
}

test_a_missing_loop_check_is_not_a_pass() {
    CASE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/mendel-smoke-test.XXXXXX")
    mkdir -p "$CASE_DIR/alone"
    cp "$SMOKE" "$CASE_DIR/alone/mendel-smoke.sh"
    committed_fixture "$CASE_DIR"
    OUT_TEXT=$(SMOKE_MENDEL_OUT="$CASE_DIR" \
        SMOKE_MENDEL_SESSION="$FIXTURES/session-healthy.jsonl" \
        bash "$CASE_DIR/alone/mendel-smoke.sh" test-model low 2>&1)
    LINE=$(echo "$OUT_TEXT" | grep '^SMOKE-MENDEL' || true)
    assert_contains "it says the loop check is missing" "$OUT_TEXT" "no loop-check.py"
    assert_contains "the loop column says unchecked" "$LINE" "loop=unchecked"
    assert_contains "and an unchecked loop is never a pass" "$LINE" "verdict=fail"
    rm -rf "$CASE_DIR"
}


echo "mendel-smoke.sh"
test_help_exits_zero
test_missing_arguments_refuse
test_counters_on_a_looped_session
test_counters_on_a_healthy_session
test_the_session_path_runs_no_pi
test_a_missing_session_log_is_a_fail
test_a_log_with_no_assistant_message_is_a_fail
test_a_committed_clean_tree_passes
test_a_loop_fails_a_committed_tree
test_a_dirty_tree_fails
test_no_commit_of_its_own_fails
test_the_cap_fails_the_smoke
test_a_missing_loop_check_is_not_a_pass

echo "mendel-smoke.sh: $PASS passed, $FAIL failed"
[ "$FAIL" = "0" ]
