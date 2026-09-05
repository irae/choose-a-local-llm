#!/bin/bash
#
# mendel-smoke.sh — the handed task that gates a full Mendel run.
#
# One question: can this config do agent work at all. It builds a small
# git repository with two files that require `xtend`, hands the model
# run 1's dependency-swap task (research/run1/results/replay-probe.sh,
# PROMPT_PARSER), runs pi once under a 25-minute cap, and prints one
# line. It never scores, it never writes a result file, and it never
# reaches the site. See docs/methodology/mendel.md, "The smoke".
#
# THE READING RULE. Read the verdict, nothing else. Pass means the
# model committed the work, left the tree clean, did not fall into a
# repetition loop, and ended inside the cap. Pass is a permit for a
# full run, not a quality signal: the counters beside it describe the
# attempt, and no number here is comparable to a scored row. A fail
# means no full run for that config; put the line in the run's results
# and drop the config or send it back to research.
#
# What it changes on the machine: nothing outside SMOKE_MENDEL_OUT. The
# fixture, the pinned pi config, and the session log all live there. It
# does NOT touch ~/.pi/agent/models.json: the pi config is a copy built
# for this run only. Reverse direction: `rm -rf` the directory the tool
# prints when it starts.
#
# Usage: mendel-smoke.sh <pi-model-id> <thinking-level>
#        mendel-smoke.sh --help
#
# Environment:
#   SMOKE_MENDEL_CAP      wall cap in seconds, default 1500 (25 min)
#   SMOKE_MENDEL_OUT      directory for the fixture, the pinned config
#                         and the session log. Default a fresh
#                         temporary directory, printed at the start.
#   SMOKE_MENDEL_BASE     server base URL for the pinned config, for
#                         example http://127.0.0.1:8081/v1. Empty keeps
#                         the base URL the owner's config already has.
#   SMOKE_MENDEL_SESSION  a session log to read instead of running pi.
#                         Verification path: it computes the counters
#                         from a log that already exists, and reports
#                         the git columns as n/a.
#
# Output, one line:
#   SMOKE-MENDEL model=<id> level=<level> calls=<n> distinct=<n>
#   longest_run=<n> loop=<LOOP|ok:ratio> commits=<n> clean=<yes|no>
#   end=<reason> wall_s=<n> verdict=<pass|fail>
#
# Validated 2026-09-05 without pi and without a GPU. The counters arm
# read three archived session logs and reproduced their published
# numbers: the Mendel row `gemma-4-12b-off-guided-v3-issue-13`
# (calls 132, LOOP at 0.02, the values in `results-guided.csv` and in
# `count-tool-calls.mjs`), and research run 2's two replay arms
# (llama-server 75 calls / 60 distinct / longest run 2 and no loop,
# the pre-fix template arm LOOP at 0.02;
# `research/run2/results/replay-llama.md`). The pi arm ran against a
# stub that commits the fixture (pass) and against a stub that runs
# past the cap (fail).

set -u

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
fi

MODEL="${1:?usage: mendel-smoke.sh <pi-model-id> <thinking-level>}"
LEVEL="${2:?usage: mendel-smoke.sh <pi-model-id> <thinking-level>}"

CAP="${SMOKE_MENDEL_CAP:-1500}"
OUT="${SMOKE_MENDEL_OUT:-$(mktemp -d /tmp/mendel-smoke.XXXXXX)}"
BASE="${SMOKE_MENDEL_BASE:-}"
GIVEN_SESSION="${SMOKE_MENDEL_SESSION:-}"

WORK="$OUT/fixture"
PI_DIR="$OUT/pi-agent"
SESSION_DIR="$OUT/session"
LOOP_CHECK="$(dirname "$0")/loop-check.py"

TASK="In lib/core/tree-hash-walker.js and lib/config/index.js, replace the xtend dependency with Object.assign. Keep the no-mutation behaviour by passing a new empty object as the first argument. Also remove xtend from package.json dependencies. Commit the work when the files are correct."

mkdir -p "$OUT"

echo "mendel-smoke: model $MODEL, thinking $LEVEL, cap ${CAP}s"
echo "mendel-smoke: everything lands in $OUT"


build_fixture() {
    rm -rf "$WORK"
    mkdir -p "$WORK/lib/core"
    mkdir -p "$WORK/lib/config"

    cat > "$WORK/lib/core/tree-hash-walker.js" <<'JSEOF'
var xtend = require('xtend');

TreeHashWalker.prototype.done = function () {
    return xtend(this._result, {error: this.error});
};

module.exports = TreeHashWalker;
JSEOF

    cat > "$WORK/lib/config/index.js" <<'JSEOF'
var xtend = require('xtend');

function loadConfig(fileConfig, config) {
    return xtend(fileConfig, config);
}

module.exports = loadConfig;
JSEOF

    cat > "$WORK/package.json" <<'JSEOF'
{
  "name": "mendel-smoke-fixture",
  "version": "1.0.0",
  "dependencies": {
    "xtend": "^4.0.2"
  }
}
JSEOF

    git -C "$WORK" init -q
    git -C "$WORK" add -A
    git -C "$WORK" -c user.name="mendel-smoke" -c user.email="smoke@localhost" \
        commit -q -m "Fixture: two files that require xtend"
    echo "mendel-smoke: fixture ready, one commit, clean tree"
}

build_pi_config() {
    rm -rf "$PI_DIR"
    mkdir -p "$PI_DIR"

    for f in models.json auth.json models-store.json; do
        [ -e "$HOME/.pi/agent/$f" ] && cp "$HOME/.pi/agent/$f" "$PI_DIR/"
    done
    printf '{"compaction":{"enabled":true},"retry":{"enabled":true}}\n' > "$PI_DIR/settings.json"

    if [ -n "$BASE" ]; then
        MODEL="$MODEL" BASE="$BASE" python3 - "$PI_DIR/models.json" <<'PYEOF'
import json
import os
import sys

path = sys.argv[1]
config = json.load(open(path))
wanted = os.environ['MODEL']
touched = []
for name, provider in config.get('providers', {}).items():
    for model in provider.get('models', []):
        if model.get('id') == wanted:
            provider['baseUrl'] = os.environ['BASE']
            touched.append(name)
json.dump(config, open(path, 'w'), indent=2)
print('mendel-smoke: base URL pinned on provider %s' % (', '.join(touched) or 'none'))
PYEOF
    fi

    echo "mendel-smoke: pi config pinned at $PI_DIR"
}

run_pi() {
    mkdir -p "$SESSION_DIR"
    local started
    started=$(date +%s)

    ( cd "$WORK" && PI_CODING_AGENT_DIR="$PI_DIR" timeout "$CAP" pi --print \
        --model "$MODEL" \
        --thinking "$LEVEL" \
        --session-dir "$SESSION_DIR" \
        "$TASK" ) > "$OUT/pi-stdout.txt" 2>&1
    PI_STATUS=$?

    WALL=$(( $(date +%s) - started ))
    SESSION="$(ls -t "$SESSION_DIR"/*.jsonl 2>/dev/null | head -1)"
    echo "mendel-smoke: pi exited $PI_STATUS after ${WALL}s, session ${SESSION:-none}"
}

count_calls() {
    CALLS=0
    DISTINCT=0
    LONGEST=0
    END=nolog
    SPAN=0
    if [ -z "${SESSION:-}" ] || [ ! -e "${SESSION:-/nonexistent}" ]; then
        return
    fi
    read -r CALLS DISTINCT LONGEST END SPAN <<< "$(python3 - "$SESSION" <<'PYEOF'
import json
import sys

calls = []
end = 'none'
first = None
last = None
for line in open(sys.argv[1], errors='replace'):
    line = line.strip()
    if not line:
        continue
    try:
        record = json.loads(line)
    except ValueError:
        continue
    if record.get('type') != 'message':
        continue
    message = record.get('message') or {}
    if message.get('role') != 'assistant':
        continue
    end = message.get('stopReason') or end
    stamp = message.get('timestamp')
    if isinstance(stamp, (int, float)):
        first = stamp if first is None else first
        last = stamp
    for part in message.get('content') or []:
        if isinstance(part, dict) and part.get('type') == 'toolCall':
            calls.append((part.get('name') or '?',
                          json.dumps(part.get('arguments'), sort_keys=True)))

longest = 1 if calls else 0
run = 1
for one, two in zip(calls, calls[1:]):
    run = run + 1 if one == two else 1
    longest = max(longest, run)

print(len(calls), len(set(calls)), longest, end,
      int((last - first) / 1000) if first and last else 0)
PYEOF
)"
}

check_loop() {
    LOOP=unchecked
    if [ -z "${SESSION:-}" ] || [ ! -e "${SESSION:-/nonexistent}" ]; then
        return
    fi
    if [ ! -e "$LOOP_CHECK" ]; then
        echo "mendel-smoke: no loop-check.py at $LOOP_CHECK" >&2
        return
    fi
    python3 "$LOOP_CHECK" "$SESSION" > "$OUT/loop.txt" 2>&1 || true
    LOOP="$(awk '
        /distinct-shape ratio=/ {
            for (i = 1; i <= NF; i++)
                if ($i ~ /^ratio=/) r = substr($i, 7)
            if (best == "" || r + 0 < best + 0) { best = r; v = $NF }
        }
        END { if (best != "") print v ":" best }
    ' "$OUT/loop.txt")"
    [ -z "$LOOP" ] && LOOP=unreadable
}

read_git() {
    COMMITS=n/a
    CLEAN=n/a
    if [ ! -d "$WORK/.git" ]; then
        return
    fi
    COMMITS=$(( $(git -C "$WORK" rev-list --count HEAD) - 1 ))
    if [ -z "$(git -C "$WORK" status --porcelain)" ]; then
        CLEAN=yes
    else
        CLEAN=no
    fi
}

decide() {
    VERDICT=pass
    case "$END" in
        cap|crash|nolog|none) VERDICT=fail ;;
    esac
    case "$LOOP" in
        ok:*) ;;
        *) VERDICT=fail ;;
    esac
    [ "$CLEAN" = "yes" ] || VERDICT=fail
    [ "$COMMITS" = "n/a" ] && VERDICT=fail
    [ "$COMMITS" != "n/a" ] && [ "$COMMITS" -lt 1 ] && VERDICT=fail
    [ "$WALL" -ge "$CAP" ] && VERDICT=fail
    return 0
}


if [ -n "$GIVEN_SESSION" ]; then
    SESSION="$GIVEN_SESSION"
    echo "mendel-smoke: reading $SESSION, no pi run"
    count_calls
    WALL="$SPAN"
else
    build_fixture
    build_pi_config
    run_pi
    count_calls
    if [ "$PI_STATUS" = "124" ]; then
        END=cap
    elif [ "$PI_STATUS" != "0" ]; then
        END=crash
    fi
fi

check_loop
read_git
decide

printf 'SMOKE-MENDEL model=%s level=%s calls=%s distinct=%s longest_run=%s loop=%s commits=%s clean=%s end=%s wall_s=%s verdict=%s\n' \
    "$MODEL" "$LEVEL" "$CALLS" "$DISTINCT" "$LONGEST" "$LOOP" \
    "$COMMITS" "$CLEAN" "$END" "$WALL" "$VERDICT"
