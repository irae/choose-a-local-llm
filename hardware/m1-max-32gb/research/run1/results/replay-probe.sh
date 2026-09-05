#!/bin/bash
#
# replay-probe.sh — the cheap arm of the goal-3 tool-call trial.
#
# Replays the two situations that the draft "Tool calls" rules target,
# as short prompts, with and without the rules. Four short runs instead
# of four full Mendel runs. If the rules do not move the numbers here,
# the full runs are not worth the machine time.
#
# Three arms, not two.
#   no-rules     the current agents-global v1.0 behaviour
#   with-rules   the draft's two behavioural paragraphs
#   with-example the same, plus one correctly formed tool call that
#                resolves pi's docs path
#
# The third arm exists because the example does two jobs at once. It
# resolves the docs location, which the draft only described, and it
# shows the exact JSON shape a tool call takes. That second job can
# plausibly move the parser-crash count, so it is worth a measurement
# rather than an opinion. See results/tool-call-trial.md.
#
# Situation A, the loop: the task names a path that does not exist. The
#   question is how many times the model repeats the identical failing
#   call before it changes approach.
# Situation B, the parser: the task needs a multi-line edit carrying
#   embedded quotes. The question is whether the tool call parses.
#
# Nothing here is scored and nothing is written to the benchmark result
# files. Sessions land in $OUT so the audit script can count them.
#
# Usage: replay-probe.sh <pi-model-id> <short-tag>

set -u

MODEL="${1:?usage: replay-probe.sh <pi-model-id> <tag>}"
TAG="${2:?usage: replay-probe.sh <pi-model-id> <tag>}"

OUT="/tmp/toolcall-trial"
WORK="$OUT/work-$TAG"
RULES="$OUT/rules.txt"
RULES_PLUS="$OUT/rules-plus-example.txt"

mkdir -p "$OUT"


write_rules() {
    cat > "$RULES" <<'RULESEOF'
## Tool calls

When a tool call fails, do not repeat the same call unchanged. Read
the error, then change something: smaller arguments, a different
tool, or a different approach. After two failures of the same call,
stop and rethink the step. Verify a path exists before you loop on
it.

Prefer several small edits over one large edit. Do not put long
multi-line text with embedded quotes into tool-call arguments; write
a file instead of editing when the change is large.
RULESEOF

    cp "$RULES" "$RULES_PLUS"
    cat >> "$RULES_PLUS" <<'PLUSEOF'
PLUSEOF
}


build_workdir() {
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
  "name": "replay-fixture",
  "version": "1.0.0",
  "dependencies": {
    "xtend": "^4.0.2"
  }
}
JSEOF
}


run_one() {
    local situation="$1"
    local arm="$2"
    local prompt="$3"
    local session_dir="$OUT/session-$TAG-$situation-$arm"

    rm -rf "$session_dir"
    mkdir -p "$session_dir"

    echo "--- $TAG / $situation / $arm ---"

    local started
    started=$(date +%s)

    if [ "$arm" = "with-rules" ]; then
        (cd "$WORK" && timeout 900 pi --print \
            --model "$MODEL" \
            --session-dir "$session_dir" \
            --append-system-prompt "$RULES" \
            "$prompt") > "$OUT/out-$TAG-$situation-$arm.txt" 2>&1
    elif [ "$arm" = "with-example" ]; then
        (cd "$WORK" && timeout 900 pi --print \
            --model "$MODEL" \
            --session-dir "$session_dir" \
            --append-system-prompt "$RULES_PLUS" \
            "$prompt") > "$OUT/out-$TAG-$situation-$arm.txt" 2>&1
    else
        (cd "$WORK" && timeout 900 pi --print \
            --model "$MODEL" \
            --session-dir "$session_dir" \
            "$prompt") > "$OUT/out-$TAG-$situation-$arm.txt" 2>&1
    fi

    local status=$?
    local elapsed=$(( $(date +%s) - started ))

    echo "  exit $status after ${elapsed}s"
}


PROMPT_LOOP="List the contents of the packages/mendel-core directory in this project and tell me which files require the xtend module. Do not modify anything."

PROMPT_PARSER="In lib/core/tree-hash-walker.js and lib/config/index.js, replace the xtend dependency with Object.assign. Keep the no-mutation behaviour by passing a new empty object as the first argument. Also remove xtend from package.json dependencies."


write_rules
echo "Model: $MODEL"
echo "Output: $OUT"
echo

for situation in loop parser; do
    for arm in no-rules with-rules with-example; do
        build_workdir
        if [ "$situation" = "loop" ]; then
            run_one "$situation" "$arm" "$PROMPT_LOOP"
        else
            run_one "$situation" "$arm" "$PROMPT_PARSER"
        fi
    done
done

echo
echo "Done. Count the calls with:"
echo "  python3 research/run1/results/count-replay.py"
