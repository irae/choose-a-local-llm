#!/bin/bash
# Tests for benchmarks/mendel-smoke.sh, through SMOKE_MENDEL_SESSION.
# The pi run needs a model and a GPU, so it stays out; these tests cover
# the counters, the loop verdict, the git columns and the pass or fail
# rule. The session logs are real Mendel logs, trimmed. The fixture and
# the pinned pi config are tested with a pi on PATH that runs nothing.

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

test_counters_on_a_compacted_session() {
    smoke_on "$FIXTURES/session-compaction.jsonl"
    assert_contains "a compacted log counts its tool calls" "$LINE" "calls=17"
    assert_contains "two real compactions" "$LINE" "compactions=2"
    assert_contains "and one split-turn record apart from them" "$LINE" "splits=1"
    assert_contains "the peak is the largest turn total, before the compaction" "$LINE" "peak=45159"
    assert_contains "the task column says which task" "$LINE" "task=xtend"
    assert_contains "and the window column says default" "$LINE" "window=default"
    assert_contains "it says where the summaries went" "$OUT_TEXT" "summaries.md"
    assert_equal "the summaries file has one section per record" \
        "$(grep -c '^## \(compaction\|split turn\) [0-9]' "$CASE_DIR/summaries.md")" "3"
    assert_contains "and names the split turn" "$(cat "$CASE_DIR/summaries.md")" "## split turn 1, tokensBefore 45159"
    rm -rf "$CASE_DIR"
}

test_the_split_turn_record_is_not_a_compaction() {
    CASE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/mendel-smoke-test.XXXXXX")
    head -n 33 "$FIXTURES/session-compaction.jsonl" > "$CASE_DIR/split-only.jsonl"
    OUT_TEXT=$(SMOKE_MENDEL_OUT="$CASE_DIR" SMOKE_MENDEL_SESSION="$CASE_DIR/split-only.jsonl" \
        bash "$SMOKE" test-model low 2>&1)
    LINE=$(echo "$OUT_TEXT" | grep '^SMOKE-MENDEL' || true)
    assert_contains "a log with only the No prior history record counts no compaction" "$LINE" "compactions=0"
    assert_contains "but counts the split" "$LINE" "splits=1"
    assert_contains "and the peak stays" "$LINE" "peak=45159"
    rm -rf "$CASE_DIR"
}

test_a_healthy_session_has_no_compaction() {
    smoke_on "$FIXTURES/session-healthy.jsonl"
    assert_contains "no compaction record counts zero" "$LINE" "compactions=0"
    assert_contains "and zero splits" "$LINE" "splits=0"
    assert_contains "the peak matches count-tool-calls.mjs" "$LINE" "peak=99611"
    assert_missing "and no summaries file is written" "$OUT_TEXT" "summaries.md"
    rm -rf "$CASE_DIR"
}

# A pi on PATH that runs nothing, and a HOME with a models.json to pin.
# The smoke then builds its fixture and its pinned config, and stops at
# the missing session log.
fake_pi_home() {
    FAKE_HOME=$(mktemp -d "${TMPDIR:-/tmp}/mendel-smoke-home.XXXXXX")
    mkdir -p "$FAKE_HOME/.pi/agent" "$FAKE_HOME/bin"
    printf '#!/bin/sh\nexit 0\n' > "$FAKE_HOME/bin/pi"
    chmod +x "$FAKE_HOME/bin/pi"
    cat > "$FAKE_HOME/.pi/agent/models.json" <<'JSONEOF'
{"providers":{"llama":{"baseUrl":"http://127.0.0.1:8081/v1","api":"openai-completions",
"models":[{"id":"test-model","contextWindow":49152,"maxTokens":8192}]}}}
JSONEOF
}

test_the_window_lands_in_the_pinned_config() {
    CASE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/mendel-smoke-test.XXXXXX")
    fake_pi_home
    OUT_TEXT=$(HOME="$FAKE_HOME" PATH="$FAKE_HOME/bin:$PATH" SMOKE_MENDEL_OUT="$CASE_DIR" \
        SMOKE_MENDEL_CONTEXT_WINDOW=28672 SMOKE_MENDEL_RESERVE_TOKENS=8192 \
        SMOKE_MENDEL_KEEP_RECENT_TOKENS=10240 \
        bash "$SMOKE" test-model low 2>&1)
    LINE=$(echo "$OUT_TEXT" | grep '^SMOKE-MENDEL' || true)
    assert_contains "it says the window is pinned" "$OUT_TEXT" "contextWindow 28672 pinned on provider llama"
    assert_contains "the pinned models.json carries the window" \
        "$(cat "$CASE_DIR/pi-agent/models.json")" '"contextWindow": 28672'
    assert_contains "the pinned settings carry the reserve" \
        "$(cat "$CASE_DIR/pi-agent/settings.json")" '"reserveTokens": 8192'
    assert_contains "and the recent budget" \
        "$(cat "$CASE_DIR/pi-agent/settings.json")" '"keepRecentTokens": 10240'
    assert_contains "the line says the window" "$LINE" "window=28672"
    assert_contains "no session log is still a fail" "$LINE" "verdict=fail"
    rm -rf "$CASE_DIR" "$FAKE_HOME"
}

test_the_default_config_pins_no_window() {
    CASE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/mendel-smoke-test.XXXXXX")
    fake_pi_home
    OUT_TEXT=$(HOME="$FAKE_HOME" PATH="$FAKE_HOME/bin:$PATH" SMOKE_MENDEL_OUT="$CASE_DIR" \
        bash "$SMOKE" test-model low 2>&1)
    assert_missing "nothing is pinned without the override" "$OUT_TEXT" "pinned on provider"
    assert_contains "the owner's window stays" \
        "$(cat "$CASE_DIR/pi-agent/models.json")" '"contextWindow":49152'
    assert_equal "and the settings pin the rule's reserve, 8192" \
        "$(cat "$CASE_DIR/pi-agent/settings.json")" \
        '{"compaction": {"enabled": true, "reserveTokens": 8192}, "retry": {"enabled": true}}'
    rm -rf "$CASE_DIR" "$FAKE_HOME"
}

test_the_wide_task_builds_ten_xtend_files() {
    CASE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/mendel-smoke-test.XXXXXX")
    fake_pi_home
    OUT_TEXT=$(HOME="$FAKE_HOME" PATH="$FAKE_HOME/bin:$PATH" SMOKE_MENDEL_OUT="$CASE_DIR" \
        SMOKE_MENDEL_TASK=xtend-wide bash "$SMOKE" test-model low 2>&1)
    LINE=$(echo "$OUT_TEXT" | grep '^SMOKE-MENDEL' || true)
    assert_contains "the fixture line names the task" "$OUT_TEXT" "fixture ready (xtend-wide, 12 files"
    assert_equal "ten files require xtend" \
        "$(grep -rl "require('xtend')" "$CASE_DIR/fixture/lib" | wc -l | tr -d ' ')" "10"
    assert_equal "two files do not" \
        "$(grep -rL "require('xtend')" "$CASE_DIR/fixture/lib" | wc -l | tr -d ' ')" "2"
    assert_contains "package.json lists xtend" "$(cat "$CASE_DIR/fixture/package.json")" '"xtend"'
    assert_equal "every file parses and loads its own helpers" \
        "$(cd "$CASE_DIR/fixture" && node -e "
            const T = require('./lib/util/timing.js');
            const t = T({label: 'x'});
            t.recordLaps('a').recordLaps('b');
            console.log(t.state({extra: 1}).laps.length, t.validate().length);
        ")" "2 0"
    assert_equal "the fixture is one commit" \
        "$(git -C "$CASE_DIR/fixture" rev-list --count HEAD)" "1"
    assert_contains "the line says the task" "$LINE" "task=xtend-wide"
    rm -rf "$CASE_DIR" "$FAKE_HOME"
}

test_an_unknown_task_refuses() {
    local out status
    out=$(SMOKE_MENDEL_TASK=nosuch bash "$SMOKE" test-model low 2>&1)
    status=$?
    assert_equal "an unknown task exits 2" "$status" "2"
    assert_contains "and names the choices" "$out" "xtend or xtend-wide"
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
test_counters_on_a_compacted_session
test_the_split_turn_record_is_not_a_compaction
test_a_healthy_session_has_no_compaction
test_the_window_lands_in_the_pinned_config
test_the_default_config_pins_no_window
test_the_wide_task_builds_ten_xtend_files
test_an_unknown_task_refuses
test_a_missing_loop_check_is_not_a_pass

echo "mendel-smoke.sh: $PASS passed, $FAIL failed"
[ "$FAIL" = "0" ]
