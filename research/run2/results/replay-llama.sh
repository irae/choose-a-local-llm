#!/bin/bash
#
# replay-llama.sh — research run 2, experiment T1.1 (AGENT.md section D,
# alternative 1). Replays the failing `google-gemma-4-12b-low-guided`
# Mendel run against llama-server instead of the LM Studio MLX path.
#
# One question: does the tool-call loop appear on a non-MLX backend?
# The LM Studio arm is already measured twice (130/30/72 and 71/30/37,
# calls / distinct / longest identical run).
#
# Two arms, selected by the first argument:
#   embedded  the GGUF's own chat template (the long one, which opens a
#             thought channel after every tool response)
#   short     the same GGUF forced onto the PRE-FIX template, Google's
#             revision 657684f of 2026-06-03, which is the file every
#             local chat_template.jinja still ships. It emits nothing
#             after a tool response. See results/container-audit.md.
#   short-dry the `short` arm again, with DRY sampling ON at a window
#             long enough to see a repeated line. `short` collapsed —
#             498 identical thinking lines in a row — so this is the
#             first configuration on this machine where a repetition
#             defence has a real repetition to defend against.
#
# `embedded` against `short` is a before-and-after of Google's
# 2026-07-15 chat-template fix, on one backend, everything else fixed.
# `short` against `short-dry` then asks whether a sampler can rescue the
# broken one.
#
# What it changes on the Mac: nothing outside /tmp, the evidence
# directory, and a fresh mendel worktree it creates itself. It does NOT
# touch ~/.pi/agent/models.json: the pi config is a pinned copy built
# under /tmp for this run only. No download: --offline forces the cache.
#
# Reverse direction: `pkill -f llama-server`, then
# `git -C ~/code/mendel worktree remove <the worktree>`. The script
# prints both paths when it starts.
#
# Owner step: none.

set -u

ARM="${1:?usage: replay-llama.sh <embedded|short> [wall-minutes]}"
WALL_MIN="${2:-150}"

MENDEL="$HOME/code/mendel"
BENCH="$HOME/code/mendel-benchmark/benchmark"
PROMPT="$HOME/.local/share/choose-a-local-llm/evidence/repro-gemma-4-12b-low-guided-full/prompt.txt"
SHORT_TEMPLATE="/tmp/run2/templates/hf-google-prefix.jinja"

MODEL_REPO="unsloth/gemma-4-12b-it-GGUF:Q4_K_XL"
MODEL_ID="gemma-4-12b-replay"
PORT=8081

# The LM Studio arm ran with a declared window of 158464, so pi compacted
# there. The same number keeps the harness variable fixed; the server
# itself serves the full 262144, which the context ramp proved fits.
DECLARED_CONTEXT=158464
SERVER_CONTEXT=262144

OUT="/tmp/run2/replay-$ARM"
EVIDENCE="$HOME/.local/share/choose-a-local-llm/evidence/run2-replay-$ARM"
WORKTREE="$HOME/code/mendel-bench-run2-replay-$ARM"
BRANCH="run2-replay-$ARM-issue-13"
PI_DIR="$OUT/pi-agent"
SERVER_LOG="$OUT/llama-server.log"


check_arm() {
    case "$ARM" in
        embedded|short|short-dry) ;;
        *)
            echo "abort: arm must be 'embedded' or 'short'" >&2
            exit 1
            ;;
    esac
    if [ "$ARM" != "embedded" ] && [ ! -f "$SHORT_TEMPLATE" ]; then
        echo "abort: $SHORT_TEMPLATE is missing; run the container audit first" >&2
        exit 1
    fi
}

check_gpu_is_free() {
    if pgrep -f "llama-server|mlx_lm" > /dev/null; then
        echo "abort: something is already serving; stop it first" >&2
        exit 1
    fi
    if pgrep -f "LM Studio" > /dev/null; then
        echo "abort: LM Studio is resident; quit the app first" >&2
        exit 1
    fi
    echo "GPU is free."
}

make_directories() {
    mkdir -p "$OUT"
    mkdir -p "$EVIDENCE"
}

start_server() {
    local template_flag=""
    if [ "$ARM" != "embedded" ]; then
        template_flag="--chat-template-file $SHORT_TEMPLATE"
    fi

    # Defaults are multiplier 0.0, which is off, and a 64-token window.
    # The window has to span several copies of whatever repeats.
    local dry_flags=""
    if [ "$ARM" = "short-dry" ]; then
        dry_flags="--dry-multiplier 0.8 --dry-base 1.75 --dry-allowed-length 2 --dry-penalty-last-n 2048"
    fi

    llama-server \
        -hf "$MODEL_REPO" \
        --alias "$MODEL_ID" \
        --no-mmproj \
        --spec-type draft-mtp \
        --spec-draft-n-max 4 \
        --parallel 1 \
        -ngl 999 \
        -fa on \
        -c "$SERVER_CONTEXT" \
        --cache-type-k q8_0 \
        --cache-type-v q8_0 \
        --jinja \
        $template_flag \
        $dry_flags \
        --offline \
        --port "$PORT" \
        > "$SERVER_LOG" 2>&1 &

    SERVER_PID=$!
    echo "llama-server pid $SERVER_PID, log $SERVER_LOG"
}

wait_for_server() {
    local waited=0
    while [ "$waited" -lt 420 ]; do
        if ! kill -0 "$SERVER_PID" 2>/dev/null; then
            echo "abort: llama-server died during load; see $SERVER_LOG" >&2
            tail -5 "$SERVER_LOG" >&2
            exit 1
        fi
        if curl -s -m 3 "http://127.0.0.1:$PORT/health" | grep -q '"ok"'; then
            echo "Server ready after ${waited}s."
            return 0
        fi
        sleep 3
        waited=$(( waited + 3 ))
    done
    echo "abort: no /health inside 420s" >&2
    exit 1
}

build_pi_config() {
    rm -rf "$PI_DIR"
    mkdir -p "$PI_DIR"

    cp "$HOME/.pi/agent/auth.json" "$PI_DIR/" 2>/dev/null
    cp "$HOME/.pi/agent/models-store.json" "$PI_DIR/" 2>/dev/null
    cp "$BENCH/agents-global.md" "$PI_DIR/AGENTS.md"
    printf '{"compaction":{"enabled":true},"retry":{"enabled":true}}\n' > "$PI_DIR/settings.json"

    MODEL_ID="$MODEL_ID" DECLARED_CONTEXT="$DECLARED_CONTEXT" PORT="$PORT" \
        python3 "$(dirname "$0")/make-replay-models.py" "$PI_DIR/models.json"

    echo "pi config pinned at $PI_DIR"
}

make_worktree() {
    if git -C "$MENDEL" show-ref --quiet "refs/heads/$BRANCH"; then
        echo "abort: branch $BRANCH exists; remove it or pick another arm name" >&2
        exit 1
    fi
    rm -rf "$WORKTREE"
    git -C "$MENDEL" worktree add -b "$BRANCH" "$WORKTREE" benchmark-guided-base
    ( cd "$WORKTREE" && pnpm install > "$OUT/install.log" 2>&1 )
    echo "worktree ready at $WORKTREE"
}

run_replay() {
    cd "$WORKTREE"
    PI_CODING_AGENT_DIR="$PI_DIR" \
    node "$BENCH/run-pi-rpc.mjs" \
        --model "$MODEL_ID" \
        --prompt "$PROMPT" \
        --out "$OUT/replay" \
        --cwd "$WORKTREE" \
        --thinking low \
        --wall-min "$WALL_MIN" \
        2> "$OUT/runner.log"
    echo "replay finished, exit $?"
}

stop_server() {
    kill "$SERVER_PID" 2>/dev/null
    wait "$SERVER_PID" 2>/dev/null
    echo "server stopped"
}

archive() {
    cp "$OUT"/replay-*.json* "$EVIDENCE/" 2>/dev/null
    cp "$OUT"/replay-*.html "$EVIDENCE/" 2>/dev/null
    cp "$SERVER_LOG" "$EVIDENCE/" 2>/dev/null
    cp "$OUT/runner.log" "$EVIDENCE/" 2>/dev/null
    echo "evidence archived to $EVIDENCE"
}


check_arm
check_gpu_is_free
make_directories
build_pi_config
make_worktree
start_server
wait_for_server
run_replay
stop_server
archive
echo "Arm $ARM done."
