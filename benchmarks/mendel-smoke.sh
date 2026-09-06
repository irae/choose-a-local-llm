#!/bin/bash
#
# mendel-smoke.sh — the handed task that gates a full Mendel run.
#
# One question: can this config do agent work at all. It builds a small
# git repository with two files that require `xtend`, hands the model
# run 1's dependency-swap task (hardware/m1-max-32gb/research/run1/results/replay-probe.sh,
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
#   SMOKE_MENDEL_TASK     which handed task: `xtend` (default, the two-file
#                         swap that gates a run) or `xtend-wide` (the same
#                         swap across ten longer files, the task of the
#                         compaction experiment. Same pass rule).
#   SMOKE_MENDEL_CONTEXT_WINDOW
#                         pins `contextWindow` for the model in the pinned
#                         models.json. Empty keeps the owner's value. This
#                         is the compaction experiment's knob: pi compacts
#                         between turns when the context passes
#                         contextWindow - reserveTokens.
#   SMOKE_MENDEL_RESERVE_TOKENS
#                         pins `compaction.reserveTokens` in the pinned
#                         settings.json. Empty keeps pi's default (16384;
#                         the pinned config never inherits the owner's).
#   SMOKE_MENDEL_KEEP_RECENT_TOKENS
#                         pins `compaction.keepRecentTokens`. Empty keeps
#                         pi's default (20000). pi cannot shrink a context
#                         below system prompt + summary + this value, so a
#                         window under that line makes pi compact on every
#                         turn. The design in
#                         hardware/m1-max-32gb/research/compaction-experiment.md
#                         says which rungs lower it.
#
# Output, one line:
#   SMOKE-MENDEL model=<id> level=<level> task=<name> window=<n|default>
#   calls=<n> distinct=<n> longest_run=<n> loop=<LOOP|ok:ratio>
#   compactions=<n> splits=<n> peak=<tokens> commits=<n> clean=<yes|no>
#   end=<reason> wall_s=<n> verdict=<pass|fail>
#
# `compactions` counts the `compaction` records of the session log whose
# summary is a real one. `splits` counts the records whose summary starts
# with "No prior history": pi wrote those when the cut fell inside one
# turn with nothing before it, and the Mendel rule never counts them as a
# compaction. A run with one prompt always gets a split first, so the
# experiment reads both. `peak` is the largest `usage.totalTokens` of one
# assistant message, the same reading as Mendel's `peak_context`. The
# verdict ignores all three.
#
# Validated 2026-09-05 without pi and without a GPU. The counters arm
# read three archived session logs and reproduced their published
# numbers: the Mendel row `gemma-4-12b-off-guided-v3-issue-13`
# (calls 132, LOOP at 0.02, the values in `results-guided.csv` and in
# `count-tool-calls.mjs`), and research run 2's two replay arms
# (llama-server 75 calls / 60 distinct / longest run 2 and no loop,
# the pre-fix template arm LOOP at 0.02;
# `hardware/m1-max-32gb/research/run2/results/replay-llama.md`). The pi arm ran against a
# stub that commits the fixture (pass) and against a stub that runs
# past the cap (fail). The compaction counters read the first 45 lines
# of the Mendel row `gemma-4-12b-low-guided-v3-issue-13` (three
# `compaction` records, one of them the split-turn marker) and agree
# with `count-tool-calls.mjs` on the peak (45159) and the calls (17).

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
TASK_NAME="${SMOKE_MENDEL_TASK:-xtend}"
WINDOW="${SMOKE_MENDEL_CONTEXT_WINDOW:-}"
RESERVE="${SMOKE_MENDEL_RESERVE_TOKENS:-}"
KEEP_RECENT="${SMOKE_MENDEL_KEEP_RECENT_TOKENS:-}"

WORK="$OUT/fixture"
PI_DIR="$OUT/pi-agent"
SESSION_DIR="$OUT/session"
LOOP_CHECK="$(dirname "$0")/loop-check.py"

case "$TASK_NAME" in
    xtend)
        TASK="In lib/core/tree-hash-walker.js and lib/config/index.js, replace the xtend dependency with Object.assign. Keep the no-mutation behaviour by passing a new empty object as the first argument. Also remove xtend from package.json dependencies. Commit the work when the files are correct."
        ;;
    xtend-wide)
        TASK="Every file under lib/ that requires xtend must stop using it. In each of those files, replace the xtend dependency with Object.assign. Keep the no-mutation behaviour by passing a new empty object as the first argument. Leave the files that do not require xtend alone. Also remove xtend from package.json dependencies. Commit the work when the files are correct."
        ;;
    *)
        echo "mendel-smoke: unknown SMOKE_MENDEL_TASK '$TASK_NAME' (xtend or xtend-wide)" >&2
        exit 2
        ;;
esac

mkdir -p "$OUT"

echo "mendel-smoke: model $MODEL, thinking $LEVEL, task $TASK_NAME, cap ${CAP}s"
echo "mendel-smoke: everything lands in $OUT"


build_fixture() {
    rm -rf "$WORK"
    if [ "$TASK_NAME" = "xtend-wide" ]; then
        write_wide_files
    else
        write_two_files
    fi

    git -C "$WORK" init -q
    git -C "$WORK" add -A
    git -C "$WORK" -c user.name="mendel-smoke" -c user.email="smoke@localhost" \
        commit -q -m "Fixture: files that require xtend"
    echo "mendel-smoke: fixture ready ($TASK_NAME, $(find "$WORK/lib" -name '*.js' | wc -l | tr -d ' ') files, $(cat "$WORK"/lib/*/*.js | wc -c | tr -d ' ') bytes under lib), one commit, clean tree"
}

write_two_files() {
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
}

write_wide_files() {
    mkdir -p "$WORK"
    python3 - "$WORK" <<'PYEOF'
import json
import os
import sys

root = sys.argv[1]

MODULES = [
    ('core', 'tree-hash-walker', 'TreeHashWalker', 'walker',
     ['hash', 'depth', 'errors', 'visited', 'pending', 'skipped'], True),
    ('core', 'tree-variation-walker', 'TreeVariationWalker', 'walker',
     ['variation', 'chain', 'depth', 'matched', 'fallback', 'pending'], True),
    ('config', 'index', 'ConfigLoader', 'loader',
     ['basedir', 'env', 'files', 'overrides', 'watched', 'stale'], True),
    ('config', 'legacy', 'LegacyConfig', 'legacy',
     ['manifest', 'aliases', 'warnings', 'upgraded', 'dropped', 'source'], True),
    ('cache', 'file-cache', 'FileCache', 'cache',
     ['entries', 'hits', 'misses', 'evicted', 'bytes', 'limit'], True),
    ('resolver', 'variation-resolver', 'VariationResolver', 'resolver',
     ['requested', 'resolved', 'missing', 'chain', 'order', 'seen'], True),
    ('watcher', 'file-watcher', 'FileWatcher', 'watcher',
     ['paths', 'events', 'debounce', 'closed', 'queued', 'ignored'], True),
    ('transform', 'source-transform', 'SourceTransform', 'transform',
     ['input', 'output', 'map', 'plugins', 'failed', 'elapsed'], True),
    ('report', 'build-report', 'BuildReport', 'report',
     ['modules', 'sizes', 'warnings', 'duration', 'largest', 'unused'], True),
    ('cli', 'options', 'CliOptions', 'options',
     ['argv', 'flags', 'positional', 'unknown', 'help', 'version'], True),
    ('util', 'path-tools', 'PathTools', 'tools',
     ['root', 'separator', 'normalized', 'relative', 'absolute', 'cached'], False),
    ('util', 'timing', 'Timing', 'timing',
     ['started', 'marks', 'laps', 'total', 'label', 'precision'], False),
]

METHODS = [
'''{cls}.prototype.normalize{Field} = function (value) {{
    if (value === undefined || value === null) {{
        return DEFAULTS.{field};
    }}
    if (Array.isArray(DEFAULTS.{field})) {{
        return Array.isArray(value) ? value.slice() : [value];
    }}
    if (typeof DEFAULTS.{field} === 'number') {{
        var parsed = Number(value);
        return isNaN(parsed) ? DEFAULTS.{field} : parsed;
    }}
    return value;
}};
''',
'''{cls}.prototype.has{Field} = function () {{
    var current = this._state.{field};
    if (Array.isArray(current)) {{
        return current.length > 0;
    }}
    if (typeof current === 'object' && current !== null) {{
        return Object.keys(current).length > 0;
    }}
    return current !== undefined && current !== DEFAULTS.{field};
}};
''',
'''{cls}.prototype.record{Field} = function (value) {{
    var previous = this._state.{field};
    var next = this.normalize{Field}(value);
    if (Array.isArray(previous)) {{
        next = previous.concat(next);
    }}
    this._history.push({{ field: '{field}', previous: previous, next: next }});
    this._state.{field} = next;
    return this;
}};
''',
'''{cls}.prototype.reset{Field} = function () {{
    var dropped = this._state.{field};
    this._state.{field} = Array.isArray(DEFAULTS.{field})
        ? DEFAULTS.{field}.slice()
        : DEFAULTS.{field};
    this._history.push({{ field: '{field}', previous: dropped, next: this._state.{field} }});
    return dropped;
}};
''',
]

TAIL = '''{cls}.prototype.describe = function () {{
    var lines = ['{cls}'];
    var state = this._state;
    Object.keys(state).forEach(function (key) {{
        var value = state[key];
        if (Array.isArray(value)) {{
            lines.push('  ' + key + ': ' + value.length + ' item(s)');
        }} else {{
            lines.push('  ' + key + ': ' + String(value));
        }}
    }});
    return lines.join('\\n');
}};

{cls}.prototype.validate = function () {{
    var problems = [];
    var state = this._state;
    Object.keys(DEFAULTS).forEach(function (key) {{
        if (!(key in state)) {{
            problems.push('missing ' + key);
            return;
        }}
        if (typeof state[key] !== typeof DEFAULTS[key]) {{
            problems.push('wrong type for ' + key);
        }}
    }});
    return problems;
}};

{cls}.prototype.history = function () {{
    return this._history.slice();
}};

{cls}.prototype.toJSON = function () {{
    return {{
        options: this.options,
        state: this.state(),
        history: this._history.length
    }};
}};

module.exports = {cls};
'''


def default_for(index):
    return [[], 0, [], {}, 'none', 8][index % 6]


def write(area, name, cls, noun, fields, uses_xtend):
    lines = []
    if uses_xtend:
        lines.append("var xtend = require('xtend');")
    lines.append("var path = require('path');")
    lines.append('')
    defaults = {field: default_for(i) for i, field in enumerate(fields)}
    lines.append('var DEFAULTS = ' + json.dumps(defaults, indent=4) + ';')
    lines.append('')
    if uses_xtend:
        merge_options = 'xtend(DEFAULTS, options)'
        merge_state = 'xtend(this._state, extra)'
    else:
        merge_options = 'Object.assign({}, DEFAULTS, options)'
        merge_state = 'Object.assign({}, this._state, extra)'
    lines.append('function %s(options) {' % cls)
    lines.append('    if (!(this instanceof %s)) {' % cls)
    lines.append('        return new %s(options);' % cls)
    lines.append('    }')
    lines.append('    this.options = %s;' % merge_options)
    lines.append("    this.basedir = path.resolve(this.options.basedir || '.');")
    lines.append('    this._state = {};')
    lines.append('    this._history = [];')
    lines.append('    var %s = this;' % noun)
    lines.append('    Object.keys(DEFAULTS).forEach(function (key) {')
    lines.append('        %s._state[key] = Array.isArray(DEFAULTS[key])' % noun)
    lines.append('            ? DEFAULTS[key].slice()')
    lines.append('            : DEFAULTS[key];')
    lines.append('    });')
    lines.append('}')
    lines.append('')
    lines.append('%s.prototype.state = function (extra) {' % cls)
    lines.append('    return %s;' % merge_state)
    lines.append('};')
    lines.append('')
    for i, field in enumerate(fields):
        for j, template in enumerate(METHODS):
            if j > 0 and (i + j) % 3 == 2:
                continue
            lines.append(template.format(cls=cls, field=field,
                                         Field=field[0].upper() + field[1:]))
    lines.append(TAIL.format(cls=cls))
    target = os.path.join(root, 'lib', area, name + '.js')
    os.makedirs(os.path.dirname(target), exist_ok=True)
    with open(target, 'w') as handle:
        handle.write('\n'.join(lines))


for module in MODULES:
    write(*module)

with open(os.path.join(root, 'package.json'), 'w') as handle:
    json.dump({
        'name': 'mendel-smoke-fixture-wide',
        'version': '1.0.0',
        'main': 'lib/config/index.js',
        'dependencies': {
            'minimist': '^1.2.8',
            'xtend': '^4.0.2',
        },
    }, handle, indent=2)
    handle.write('\n')
PYEOF
}

build_pi_config() {
    rm -rf "$PI_DIR"
    mkdir -p "$PI_DIR"

    for f in models.json auth.json models-store.json; do
        [ -e "$HOME/.pi/agent/$f" ] && cp "$HOME/.pi/agent/$f" "$PI_DIR/"
    done
    RESERVE="$RESERVE" KEEP_RECENT="$KEEP_RECENT" python3 - "$PI_DIR/settings.json" <<'PYEOF'
import json
import os
import sys

compaction = {'enabled': True}
if os.environ['RESERVE']:
    compaction['reserveTokens'] = int(os.environ['RESERVE'])
if os.environ['KEEP_RECENT']:
    compaction['keepRecentTokens'] = int(os.environ['KEEP_RECENT'])
json.dump({'compaction': compaction, 'retry': {'enabled': True}}, open(sys.argv[1], 'w'))
print('mendel-smoke: compaction settings %s' % json.dumps(compaction))
PYEOF

    if [ -n "$BASE" ] || [ -n "$WINDOW" ]; then
        MODEL="$MODEL" BASE="$BASE" WINDOW="$WINDOW" python3 - "$PI_DIR/models.json" <<'PYEOF'
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
            if os.environ['BASE']:
                provider['baseUrl'] = os.environ['BASE']
            if os.environ['WINDOW']:
                model['contextWindow'] = int(os.environ['WINDOW'])
            touched.append(name)
    override = provider.get('modelOverrides', {}).get(wanted)
    if override is not None and os.environ['WINDOW']:
        override['contextWindow'] = int(os.environ['WINDOW'])
        touched.append(name + ' (modelOverrides)')
json.dump(config, open(path, 'w'), indent=2)
what = []
if os.environ['BASE']:
    what.append('base URL')
if os.environ['WINDOW']:
    what.append('contextWindow %s' % os.environ['WINDOW'])
print('mendel-smoke: %s pinned on provider %s' % (' and '.join(what), ', '.join(touched) or 'none'))
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
    COMPACTIONS=0
    SPLITS=0
    PEAK=0
    if [ -z "${SESSION:-}" ] || [ ! -e "${SESSION:-/nonexistent}" ]; then
        return
    fi
    read -r CALLS DISTINCT LONGEST END SPAN COMPACTIONS SPLITS PEAK <<< "$(python3 - "$SESSION" "$OUT/summaries.md" <<'PYEOF'
import json
import sys

calls = []
end = 'none'
first = None
last = None
compactions = 0
splits = 0
peak = 0
summaries = []
for line in open(sys.argv[1], errors='replace'):
    line = line.strip()
    if not line:
        continue
    try:
        record = json.loads(line)
    except ValueError:
        continue
    if record.get('type') == 'compaction':
        summary = record.get('summary') or ''
        if summary.startswith('No prior history'):
            splits += 1
            kind = 'split turn'
        else:
            compactions += 1
            kind = 'compaction'
        summaries.append('## %s %d, tokensBefore %s\n\n%s\n' % (
            kind, compactions + splits, record.get('tokensBefore'), summary))
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
    usage = message.get('usage') or {}
    total = usage.get('totalTokens') or sum(
        usage.get(key) or 0 for key in ('input', 'cacheRead', 'cacheWrite', 'output'))
    peak = max(peak, total)
    for part in message.get('content') or []:
        if isinstance(part, dict) and part.get('type') == 'toolCall':
            calls.append((part.get('name') or '?',
                          json.dumps(part.get('arguments'), sort_keys=True)))

longest = 1 if calls else 0
run = 1
for one, two in zip(calls, calls[1:]):
    run = run + 1 if one == two else 1
    longest = max(longest, run)

if summaries:
    with open(sys.argv[2], 'w') as handle:
        handle.write('\n'.join(summaries))

print(len(calls), len(set(calls)), longest, end,
      int((last - first) / 1000) if first and last else 0,
      compactions, splits, peak)
PYEOF
)"
    [ -e "$OUT/summaries.md" ] && echo "mendel-smoke: the summaries pi wrote are in $OUT/summaries.md"
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

printf 'SMOKE-MENDEL model=%s level=%s task=%s window=%s calls=%s distinct=%s longest_run=%s loop=%s compactions=%s splits=%s peak=%s commits=%s clean=%s end=%s wall_s=%s verdict=%s\n' \
    "$MODEL" "$LEVEL" "$TASK_NAME" "${WINDOW:-default}" "$CALLS" "$DISTINCT" "$LONGEST" "$LOOP" \
    "$COMPACTIONS" "$SPLITS" "$PEAK" "$COMMITS" "$CLEAN" "$END" "$WALL" "$VERDICT"
