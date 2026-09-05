#!/bin/bash
#
# lmstudio-thinking-probe.sh — research run 2. Answers whether the
# thinking-off config behind the best Gemma-12B EvalPlus score
# (0.909/0.872, 100% completion) can still be reproduced today.
#
# Why it matters: that score was measured on 2026-08-28 with thinking off
# by DEFAULT — the client sent no `enable_thinking`, and the template's
# `default(false)` made it false. A later note in the report says current
# engine builds always think, which would make the config irreproducible
# and would block a Mendel run on the only Gemma-12B config that scores
# well. The two statements are from different dates and cannot both be
# checked from archives.
#
# It loads the model ONCE and does not cycle. Run 1's kernel panic came
# from repeated load and unload of this model with a client connecting;
# the owner reports a year of use without one. Loading once avoids the
# pattern either way.
#
# Three requests, same model, same server:
#   1. no `enable_thinking` in the body    — the 0.909 run's shape
#   2. `enable_thinking: false` explicitly
#   3. `enable_thinking: true` explicitly
# For each: is `reasoning_content` populated, and how long is it.
#
# What it changes on the Mac: it starts LM Studio's server and loads one
# model. It unloads and stops the server at the end.
#
# Reverse direction: the script does it. If interrupted, run
# `~/.cache/lm-studio/bin/lms unload --all` then
# `~/.cache/lm-studio/bin/lms server stop`.
#
# Owner step: none, but the owner asked to be present for this one.

set -u

LMS="$HOME/.cache/lm-studio/bin/lms"
MODEL_KEY="gemma-4-12b-it-mlx"
PORT=8081
OUT="/tmp/run2/lmstudio-probe"
EVIDENCE="$HOME/.local/share/choose-a-local-llm/evidence/run2-lmstudio-probe"

PROMPT="Write a Python function that returns the nth Fibonacci number."


check_gpu_is_free() {
    if pgrep -f "[l]lama-serv|[m]lx_lm" > /dev/null; then
        echo "abort: another server is running; stop it first" >&2
        exit 1
    fi
    echo "GPU is free."
}

make_directories() {
    mkdir -p "$OUT"
    mkdir -p "$EVIDENCE"
}

record_engine_version() {
    ls -dt "$HOME"/.cache/lm-studio/extensions/backends/mlx-llm-* \
        | sed 's|.*/||' > "$OUT/engine-builds.txt"
    echo "installed MLX engine builds:"
    cat "$OUT/engine-builds.txt" | sed 's/^/  /'
}

start_server_and_load_once() {
    "$LMS" server start --port "$PORT" > "$OUT/server-start.log" 2>&1
    sleep 3
    echo "loading $MODEL_KEY once"
    "$LMS" load "$MODEL_KEY" --gpu max -y > "$OUT/load.log" 2>&1
    sleep 3
    "$LMS" server status > "$OUT/server-status.log" 2>&1
    cat "$OUT/server-status.log" | sed 's/^/  /'
}

probe() {
    local label="$1"
    local kwargs="$2"
    local body

    if [ -z "$kwargs" ]; then
        body="{\"model\":\"$MODEL_KEY\",\"messages\":[{\"role\":\"user\",\"content\":\"$PROMPT\"}],\"max_tokens\":600,\"temperature\":0}"
    else
        body="{\"model\":\"$MODEL_KEY\",\"messages\":[{\"role\":\"user\",\"content\":\"$PROMPT\"}],\"max_tokens\":600,\"temperature\":0,\"chat_template_kwargs\":$kwargs}"
    fi

    curl -s -m 300 "http://127.0.0.1:$PORT/v1/chat/completions" \
        -H 'Content-Type: application/json' \
        -d "$body" > "$OUT/reply-$label.json" 2>&1

    python3 - "$OUT/reply-$label.json" "$label" <<'PYEOF'
import json
import sys

path, label = sys.argv[1], sys.argv[2]
try:
    d = json.load(open(path))
except Exception as e:
    print('  %-22s UNPARSEABLE (%s)' % (label, type(e).__name__))
    sys.exit(0)

if 'choices' not in d:
    print('  %-22s ERROR: %s' % (label, json.dumps(d)[:120]))
    sys.exit(0)

msg = d['choices'][0].get('message') or {}
reasoning = msg.get('reasoning_content') or msg.get('reasoning') or ''
content = msg.get('content') or ''
finish = d['choices'][0].get('finish_reason')
print('  %-22s reasoning=%-6d content=%-6d finish=%-8s thinking=%s'
      % (label, len(reasoning), len(content), finish,
         'ON' if reasoning.strip() else 'OFF'))
PYEOF
}

stop_everything() {
    "$LMS" unload --all > "$OUT/unload.log" 2>&1
    "$LMS" server stop > "$OUT/server-stop.log" 2>&1
    echo "model unloaded, server stopped"
}

archive() {
    cp "$OUT"/*.json "$OUT"/*.log "$OUT"/*.txt "$EVIDENCE/" 2>/dev/null
    echo "evidence archived to $EVIDENCE"
}


check_gpu_is_free
make_directories
record_engine_version
start_server_and_load_once

echo ""
echo "results:"
probe "no-kwarg"        ""
probe "thinking-false"  '{"enable_thinking":false}'
probe "thinking-true"   '{"enable_thinking":true}'
echo ""

stop_everything
archive
echo "Probe done."
