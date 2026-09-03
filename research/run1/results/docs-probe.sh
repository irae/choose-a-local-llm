#!/bin/bash
#
# docs-probe.sh — does the "read the docs" instruction actually work?
#
# Before spending model time on the Mendel task, check that the rule text
# does what it claims: get a model to find pi's own documentation and
# answer from it. If a strong model cannot follow the instruction, the
# instruction is wrong and no local model will save it.
#
# The question has one checkable answer that is not guessable and lives
# only in pi's docs: PI_TUI_ESC_TIMEOUT defaults to 100 ms over SSH and
# 10 ms otherwise.
#
# Arms:
#   bare     the question alone, no help
#   example  the question plus the draft rule carrying one correctly
#            formed tool call that resolves the docs path
#
# A model that answers correctly in the bare arm tells us the question is
# too easy or the answer leaked into training. A model that answers only
# in the example arm tells us the rule earns its place.
#
# Usage: docs-probe.sh <pi-model-id> <tag> [runs-per-arm]

set -u

MODEL="${1:?usage: docs-probe.sh <pi-model-id> <tag> [runs]}"
TAG="${2:?usage: docs-probe.sh <pi-model-id> <tag> [runs]}"
RUNS="${3:-1}"

OUT="/tmp/docs-probe"
WORK="$OUT/work"
RULE="$OUT/rule.txt"

mkdir -p "$OUT" "$WORK"


write_rule() {
    cat > "$RULE" <<'RULEEOF'
## Tool calls

When a tool call fails, do not repeat the same call unchanged. Read
the error, then change something: smaller arguments, a different
tool, or a different approach. After two failures of the same call,
stop and rethink the step. Verify a path exists before you loop on
it.

Prefer several small edits over one large edit. Do not put long
multi-line text with embedded quotes into tool-call arguments; write
a file instead of editing when the change is large.

Your harness (pi) ships its documentation offline. When you need
to know how pi itself behaves — compaction, sessions, skills,
settings — read its index:

{"type":"toolCall","name":"bash","arguments":{"command":"cat \"$(npm root -g)/@earendil-works/pi-coding-agent/docs/index.md\""}}

It lists every document with one line each. Your tools are already
described to you; the docs do not cover them.
RULEEOF
}


QUESTION="What is the default value of the PI_TUI_ESC_TIMEOUT setting, and does it differ when running over SSH? Answer with the two numbers and their units."


run_one() {
    local arm="$1"
    local index="$2"
    local session_dir="$OUT/session-$TAG-$arm-$index"

    rm -rf "$session_dir"
    mkdir -p "$session_dir"

    local started
    started=$(date +%s)

    if [ "$arm" = "example" ]; then
        (cd "$WORK" && timeout 600 pi --print \
            --model "$MODEL" \
            --session-dir "$session_dir" \
            --append-system-prompt "$RULE" \
            "$QUESTION") > "$OUT/out-$TAG-$arm-$index.txt" 2>&1
    else
        (cd "$WORK" && timeout 600 pi --print \
            --model "$MODEL" \
            --session-dir "$session_dir" \
            "$QUESTION") > "$OUT/out-$TAG-$arm-$index.txt" 2>&1
    fi

    local status=$?
    local elapsed=$(( $(date +%s) - started ))

    local answer="WRONG"
    if grep -qE "\b100\b" "$OUT/out-$TAG-$arm-$index.txt" \
       && grep -qE "\b10\b" "$OUT/out-$TAG-$arm-$index.txt"; then
        answer="CORRECT"
    fi

    printf "  %-8s run %s: exit %s, %3ds, %s\n" \
        "$arm" "$index" "$status" "$elapsed" "$answer"
}


write_rule
echo "Model: $MODEL   runs per arm: $RUNS"

for arm in bare example; do
    index=1
    while [ "$index" -le "$RUNS" ]; do
        run_one "$arm" "$index"
        index=$(( index + 1 ))
    done
done

echo
echo "Answers and call counts:"
python3 "$(dirname "$0")/count-replay.py" "$OUT" 2>/dev/null | head -20
