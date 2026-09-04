#!/bin/bash
#
# replay-mlx.sh — research run 2. Moves the template result from
# llama.cpp onto the MLX path, which is where the published Gemma-12B
# rows were actually measured.
#
# Last night's arms proved the pre-fix chat template collapses
# Gemma-4-12B on llama-server. Our MLX containers ship that same pre-fix
# template and `AutoTokenizer` resolves to it, so the published rows ran
# on it. This asks the question directly on `mlx_lm.server`.
#
# Two arms:
#   default  the container as it is, so the stale pre-fix template
#            resolved from chat_template.jinja
#   fixed    the same container with `--chat-template` overriding it
#            with Google's current post-fix template
#
# **No container is modified.** The override is a server flag, so the
# owner's model directory is untouched either way. That matters: editing
# chat_template.jinja would change a container behind published rows.
#
# What it changes on the Mac: nothing outside /tmp, the evidence
# directory, and a fresh mendel worktree it creates. No download.
#
# Reverse direction: `pkill -f mlx_lm`, then
# `git -C ~/code/mendel worktree remove <the worktree>`.
#
# Owner step: none. Needs the GPU free.

set -u

ARM="${1:?usage: replay-mlx.sh <default|fixed> [wall-minutes]}"
WALL_MIN="${2:-100}"

MENDEL="$HOME/code/mendel"
BENCH="$HOME/code/mendel-benchmark/benchmark"
PROMPT="$HOME/.local/share/choose-a-local-llm/evidence/repro-gemma-4-12b-low-guided-full/prompt.txt"
POSTFIX_TEMPLATE="/tmp/run2/templates/hf-google-main.jinja"

MODEL="mlx-community/gemma-4-12B-it-4bit"
MODEL_ID="$MODEL"   # pi entry id must match what the server answers to
PORT=8081

# Deliberately smaller than the 158464 the llama.cpp arms declared.
# `mlx_lm.server` has no window of its own and dies with a Metal OOM at
# its ceiling (see qwen38-ceiling.md), so a large declared window would
# risk ending the arm on memory rather than on behaviour. Both collapses
# measured so far began well under 32K of prompt, so this does not hide
# the effect. Recorded as a deviation from the llama.cpp arms.
DECLARED_CONTEXT=32768

OUT="/tmp/run2/replay-mlx-$ARM"
EVIDENCE="$HOME/.local/share/choose-a-local-llm/evidence/run2-replay-mlx-$ARM"
WORKTREE="$HOME/code/mendel-bench-run2-mlx-$ARM"
BRANCH="run2-mlx-$ARM-issue-13"
PI_DIR="$OUT/pi-agent"
SERVER_LOG="$OUT/mlx-server.log"


check_arm() {
    case "$ARM" in
        default|fixed) ;;
        *)
            echo "abort: arm must be 'default' or 'fixed'" >&2
            exit 1
            ;;
    esac
    if [ "$ARM" = "fixed" ] && [ ! -f "$POSTFIX_TEMPLATE" ]; then
        echo "abort: $POSTFIX_TEMPLATE is missing; run the container audit first" >&2
        exit 1
    fi
}

check_gpu_is_free() {
    if pgrep -f "[l]lama-serv|[m]lx_lm" > /dev/null; then
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
    if [ "$ARM" = "fixed" ]; then
        HF_HUB_OFFLINE=1 mlx_lm.server \
            --model "$MODEL" \
            --prompt-cache-size 2 \
            --chat-template "$(cat "$POSTFIX_TEMPLATE")" \
            --port "$PORT" \
            > "$SERVER_LOG" 2>&1 &
    else
        HF_HUB_OFFLINE=1 mlx_lm.server \
            --model "$MODEL" \
            --prompt-cache-size 2 \
            --port "$PORT" \
            > "$SERVER_LOG" 2>&1 &
    fi

    SERVER_PID=$!
    echo "mlx_lm.server pid $SERVER_PID, arm $ARM, log $SERVER_LOG"
}

wait_for_server() {
    local waited=0
    while [ "$waited" -lt 480 ]; do
        if ! kill -0 "$SERVER_PID" 2>/dev/null; then
            echo "abort: mlx_lm.server died during load; see $SERVER_LOG" >&2
            tail -5 "$SERVER_LOG" >&2
            exit 1
        fi
        if curl -s -m 3 -o /dev/null "http://127.0.0.1:$PORT/v1/models"; then
            echo "Server ready after ${waited}s."
            return 0
        fi
        sleep 3
        waited=$(( waited + 3 ))
    done
    echo "abort: no /v1/models inside 480s" >&2
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
    PROVIDER=mlx SERVED_MODEL="$MODEL" \
        python3 "$(dirname "$0")/make-replay-models.py" "$PI_DIR/models.json"

    echo "pi config pinned at $PI_DIR"
}

make_worktree() {
    if git -C "$MENDEL" show-ref --quiet "refs/heads/$BRANCH"; then
        echo "abort: branch $BRANCH exists" >&2
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
    echo "replay finished"
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
echo "MLX arm $ARM done."
