#!/bin/bash
#
# llama-router.sh — the long-running llama-server of this machine, in
# router mode: one process, every preset of hardware/<id>/models.ini,
# one model loaded at a time, loaded on the first request that names it.
#
#   tools/llama-router.sh start [prism]   start if not running; restart if
#                                         the preset file changed
#   tools/llama-router.sh status [prism]
#   tools/llama-router.sh stop [prism]
#   tools/llama-router.sh install [prism] write the systemd user unit
#
# Two builds exist: the official llama.cpp (default) with
# hardware/<id>/models.ini, and the PrismML build (`prism`) with
# hardware/<id>/models-prism-llama.ini, the only one that loads the
# ternary Bonsai files. Both listen on 0.0.0.0:8080 with CORS open, for
# pi on this machine, on the LAN and over the tailnet, so pi has one
# provider and one port. **Only one runs at a time** (owner, 2026-09-22):
# `start` refuses while the other is up, and says so; stop it first.
# A run that needs a model asks the running server by pi id; it starts
# no server of its own.
#
# The official build is the newest one under
# ~/.local/share/choose-a-local-llm/llama.cpp/, the same build every run
# uses, and `llama-server` on PATH only when that directory is absent.
# The PATH binary of a distribution package can carry no GPU backend, so
# `start` first asks the chosen binary for its devices and refuses when
# it names none.
#
# After ROUTER_IDLE seconds the model goes to `sleeping`: the child
# server stays, the GPU memory goes back (8632 MiB to 944 MiB, measured
# 2026-09-23). The next request wakes it. `sleeping` means the card is
# free; only `loaded` holds it.
#
# Environment:
#   ROUTER_PORT       8080
#   ROUTER_HOST       0.0.0.0
#   ROUTER_PRESET     the preset file
#   ROUTER_BIN        the llama-server binary
#   ROUTER_MODELS_MAX 1
#   ROUTER_IDLE       seconds of idleness before the loaded model sleeps
#                     (default 300)

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
ID="$(hostname -s | tr '[:upper:]' '[:lower:]')"
ACTION="${1:-}"
ROUTER="${2:-${ROUTER:-official}}"
PORT="${ROUTER_PORT:-8080}"
OFFICIAL_BIN_DIR="$(ls -d "$HOME"/.local/share/choose-a-local-llm/llama.cpp/*/bin 2>/dev/null | sort | tail -1 || true)"
if [ -n "$OFFICIAL_BIN_DIR" ]; then
    OFFICIAL_LIB_DIR="$(dirname "$OFFICIAL_BIN_DIR")/lib"
else
    OFFICIAL_LIB_DIR=""
fi
if [ "$ROUTER" = prism ]; then
    PRESET="${ROUTER_PRESET:-$REPO/hardware/$ID/models-prism-llama.ini}"
    LABEL="llama (prism-ml)"
    OTHER=llama-router
    OTHER_LABEL="llama (official)"
    PRISM_DIR="$(ls -d "$HOME"/.local/share/choose-a-local-llm/llama.cpp-prism/release/bin/llama-prism-* 2>/dev/null | sort | tail -1 || true)"
    BIN="${ROUTER_BIN:-$PRISM_DIR/llama-server}"
    export LD_LIBRARY_PATH="$PRISM_DIR${OFFICIAL_LIB_DIR:+:$OFFICIAL_LIB_DIR}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    UNIT=llama-router-prism
elif [ "$ROUTER" = official ]; then
    PRESET="${ROUTER_PRESET:-$REPO/hardware/$ID/models.ini}"
    BIN="${ROUTER_BIN:-$OFFICIAL_BIN_DIR/llama-server}"
    [ -x "$BIN" ] || BIN="$(command -v llama-server)"
    if [ -n "$OFFICIAL_LIB_DIR" ]; then
        export LD_LIBRARY_PATH="$OFFICIAL_LIB_DIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    fi
    LABEL="llama (official)"
    OTHER=llama-router-prism
    OTHER_LABEL="llama (prism-ml)"
    UNIT=llama-router
else
    echo "unknown build '$ROUTER': use 'prism' or nothing (official)" >&2
    exit 2
fi
HOST="${ROUTER_HOST:-0.0.0.0}"
MODELS_MAX="${ROUTER_MODELS_MAX:-1}"
IDLE="${ROUTER_IDLE:-300}"
STATE="$HOME/.local/share/choose-a-local-llm/$UNIT.hash"
HAS_SYSTEMD=0
command -v systemctl > /dev/null 2>&1 && systemctl --user show-environment > /dev/null 2>&1 && HAS_SYSTEMD=1

hash_preset() { sha256sum "$PRESET" | cut -c1-16; }

running() {
    if [ "$HAS_SYSTEMD" = 1 ]; then
        systemctl --user is-active --quiet "$UNIT"
    else
        pgrep -f "llama-server --models-preset $PRESET" > /dev/null
    fi
}

other_running() {
    if [ "$HAS_SYSTEMD" = 1 ]; then
        systemctl --user is-active --quiet "$OTHER"
    else
        pgrep -f "llama-server --models-preset" | xargs -r ps -o args= -p 2> /dev/null | grep -v -F "$PRESET" | grep -q models-preset
    fi
}

loaded() {
    curl -sf "http://127.0.0.1:$PORT/models" 2> /dev/null \
        | python3 -c 'import json,sys; d=json.load(sys.stdin)["data"]; live=[m["id"] for m in d if m["status"]["value"] not in ("unloaded","sleeping")]; nap=[m["id"] for m in d if m["status"]["value"]=="sleeping"]; print(", ".join(live) or ("none, asleep: " + ", ".join(nap) if nap else "none"))' 2> /dev/null || echo "no answer"
}

has_device() {
    "$BIN" --list-devices 2> /dev/null | grep -qE '^[[:space:]]+[A-Za-z]+[0-9]+:'
}

serve() {
    exec "$BIN" --models-preset "$PRESET" --models-max "$MODELS_MAX" \
        --host "$HOST" --port "$PORT" --cors-origins '*' --sleep-idle-seconds "$IDLE"
}

unit_file() {
    cat <<EOF
[Unit]
Description=$LABEL router for choose-a-local-llm
After=network.target

[Service]
Type=exec
ExecStart=$REPO/tools/llama-router.sh serve $ROUTER
Restart=on-failure
RestartSec=5
TimeoutStopSec=60

[Install]
WantedBy=default.target
EOF
}

case "$ACTION" in
    serve) serve ;;
    install)
        [ "$HAS_SYSTEMD" = 1 ] || { echo "no systemd user session; use 'start'" >&2; exit 1; }
        mkdir -p "$HOME/.config/systemd/user"
        unit_file > "$HOME/.config/systemd/user/$UNIT.service"
        systemctl --user daemon-reload
        systemctl --user enable "$UNIT" > /dev/null 2>&1
        echo "installed $UNIT.service; 'start' brings it up, logs: journalctl --user -u $UNIT"
        ;;
    start)
        if other_running; then
            echo "$OTHER_LABEL is already running on port $PORT. Stop it first: tools/llama-router.sh stop$([ "$ROUTER" = official ] && echo ' prism')" >&2
            exit 1
        fi
        [ -f "$PRESET" ] || { echo "no preset file $PRESET; run npm run docs:tables" >&2; exit 1; }
        if ! has_device; then
            echo "$BIN lists no GPU device. It would serve on the CPU, at about one token per second, and it would swap. Install the GPU backend for that binary, or set ROUTER_BIN to a build that finds the card ('<build>/bin/llama-server --list-devices' must name one)." >&2
            exit 1
        fi
        mkdir -p "$(dirname "$STATE")"
        want="$(hash_preset)"
        have="$(cat "$STATE" 2> /dev/null || true)"
        if running && [ "$want" = "$have" ]; then
            echo "$LABEL running, preset $want unchanged, loaded: $(loaded)"
            exit 0
        fi
        if running; then
            echo "$LABEL running with preset $have, file is $want: restarting"
            "$0" stop "$ROUTER"
        fi
        echo "$want" > "$STATE"
        pkill -f "llama-server --models-preset $PRESET" 2> /dev/null && sleep 2 || true
        if [ "$HAS_SYSTEMD" = 1 ]; then
            [ -f "$HOME/.config/systemd/user/$UNIT.service" ] || "$0" install "$ROUTER"
            systemctl --user restart "$UNIT"
        else
            nohup "$0" serve > "$HOME/.local/share/choose-a-local-llm/$UNIT.log" 2>&1 &
        fi
        for _ in $(seq 1 30); do
            curl -sf "http://127.0.0.1:$PORT/health" > /dev/null 2>&1 && { echo "$LABEL up on $HOST:$PORT, preset $want"; exit 0; }
            sleep 1
        done
        echo "$LABEL did not answer on $PORT" >&2
        exit 1
        ;;
    stop)
        if [ "$HAS_SYSTEMD" = 1 ]; then
            systemctl --user stop "$UNIT"
        else
            pkill -f "llama-server --models-preset $PRESET" || true
        fi
        echo "$LABEL stopped"
        ;;
    status)
        if running; then
            echo "$LABEL running on $HOST:$PORT, preset $(cat "$STATE" 2> /dev/null || echo '?') (file $(hash_preset)), loaded: $(loaded)"
        else
            echo "$LABEL not running$(other_running && echo "; $OTHER_LABEL is")"
            exit 1
        fi
        ;;
    *) sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'; exit 2 ;;
esac
