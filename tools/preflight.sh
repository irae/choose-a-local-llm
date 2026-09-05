#!/bin/bash
#
# preflight.sh — read the machine and say if a run can start.
#
# It changes NOTHING. No sudo, no launchctl write, no reboot, no
# process start or stop. It only reads, and it prints one line per
# check:
#
#   ok    the machine is ready for this check
#   fix   a step is needed; the line says the exact command
#   ask   the script cannot decide; a human must look
#
# Exit 0 when every line is "ok", 1 otherwise. A machine that prints
# all "ok" starts the run with no question and no turn-off.
#
# The machine's own values come from the machine file,
# ~/.config/choose-a-local-llm/machine.md. See
# tools/README-mac-services.md for the file and its tables.
#
# Environment variables:
#   PREFLIGHT_MACHINE_FILE   machine file path
#                            (default $XDG_CONFIG_HOME/choose-a-local-llm/machine.md)
#   PREFLIGHT_WIRED_LIMIT_MB accepted iogpu.wired_limit_mb values, space
#                            separated (default: the numbers in the
#                            machine file's Thresholds row)
#   PREFLIGHT_BALLOON_FREE_MB free memory above which the balloon is
#                            skipped (default: the machine file's row)
#   PREFLIGHT_PROBE_PORT     loopback port for the network probe
#                            (default 8081, the run port)
#   PREFLIGHT_START_WIRED_FILE  file holding the last recorded start
#                            value of wired MB (default
#                            $XDG_CONFIG_HOME/choose-a-local-llm/last-start-wired-mb)

set -u

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/choose-a-local-llm"
MACHINE_FILE="${PREFLIGHT_MACHINE_FILE:-$CONFIG_DIR/machine.md}"
STATE_FILE="$CONFIG_DIR/services-state"
START_WIRED_FILE="${PREFLIGHT_START_WIRED_FILE:-$CONFIG_DIR/last-start-wired-mb}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROBE_PORT="${PREFLIGHT_PROBE_PORT:-8081}"

# App rows of the machine file this script knows how to check. An app
# row it does not know becomes an "ask" line.
KNOWN_APPS="
Little Snitch
LM Studio
Docker
Background login items
"

GPU_PROCESS_PATTERN="llama-server|mlx_lm"
LMSTUDIO_PROCESS_PATTERN="LM Studio.app/Contents/MacOS/LM Studio"
DOCKER_PROCESS_PATTERN="Docker Desktop|com.docker.backend|Docker.app/Contents/MacOS"

exit_code=0
reboot_reasons=""


report() {
    local status="$1"
    local name="$2"
    local text="$3"

    printf '%-4s %-14s %s\n' "$status" "$name" "$text"

    if [ "$status" != "ok" ]; then
        exit_code=1
    fi
}


usage() {
    cat <<'EOF'
usage: preflight.sh [--help]

Reads the machine and prints one line per check: ok, fix or ask.
Changes nothing. Exit 0 when every line is ok, 1 otherwise.

Checks:
  gpu-free       no llama-server, no mlx_lm, no LM Studio app, no Docker
  apps           every app row of the machine file has a check here
  login-items    mac-services.sh status: the listed items are off already
  little-snitch  a fresh binary path can reach the run port
  wired-limit    iogpu.wired_limit_mb matches the machine file
  memory         the starting numbers: wired, free, swap, balloon verdict
  reboot         the checklist's three reboot conditions

The values come from ~/.config/choose-a-local-llm/machine.md. The
header of this file lists the environment variables that override them.
EOF
}


# Reads one Setting cell of a machine file table. The table shape it
# expects: a "## <section>" heading, then rows "| key | setting | note |".
# Backticks and spaces around the key are ignored.
machine_setting() {
    local section="$1"
    local key="$2"

    if [ ! -f "$MACHINE_FILE" ]; then
        return 0
    fi

    awk -v section="$section" -v key="$key" '
        /^## / {
            wanted = (substr($0, 4) == section)
            next
        }
        wanted != 1 { next }
        /^\|/ {
            split($0, cell, "|")
            gsub(/^[ \t`]+|[ \t`]+$/, "", cell[2])
            gsub(/^[ \t]+|[ \t]+$/, "", cell[3])
            if (cell[2] == key) {
                print cell[3]
                exit
            }
        }
    ' "$MACHINE_FILE"
}


# Prints the App column of the "Apps to handle before a run" table.
machine_apps() {
    if [ ! -f "$MACHINE_FILE" ]; then
        return 0
    fi

    awk '
        /^## / {
            wanted = (substr($0, 4) == "Apps to handle before a run")
            next
        }
        wanted != 1 { next }
        /^\|/ {
            split($0, cell, "|")
            gsub(/^[ \t`]+|[ \t`]+$/, "", cell[2])
            if (cell[2] == "App") { next }
            if (cell[2] ~ /^-+$/) { next }
            if (cell[2] == "") { next }
            print cell[2]
        }
    ' "$MACHINE_FILE"
}


numbers_in() {
    echo "$1" | grep -o '[0-9][0-9]*'
}


add_reboot_reason() {
    reboot_reasons="$reboot_reasons$1
"
}


check_gpu_free() {
    local servers
    servers=$(pgrep -fl "$GPU_PROCESS_PATTERN" 2>/dev/null)

    if [ -n "$servers" ]; then
        report fix gpu-free "a model server runs: $(echo "$servers" | head -1 | cut -c1-60). Stop it."
    else
        report ok gpu-free "no llama-server and no mlx_lm"
    fi

    if pgrep -f "$LMSTUDIO_PROCESS_PATTERN" >/dev/null 2>&1; then
        report fix gpu-free "LM Studio app runs. osascript -e 'quit app \"LM Studio\"'"
    else
        report ok gpu-free "LM Studio app is not running"
    fi

    if pgrep -f "$DOCKER_PROCESS_PATTERN" >/dev/null 2>&1; then
        report fix gpu-free "Docker runs. Quit it; it does not fit beside a model."
    else
        report ok gpu-free "Docker is not running"
    fi
}


check_apps() {
    local app

    if [ ! -f "$MACHINE_FILE" ]; then
        report ask apps "no machine file at $MACHINE_FILE"
        return 0
    fi

    for app in $(machine_apps | tr ' ' '_'); do
        app=$(echo "$app" | tr '_' ' ')

        if echo "$KNOWN_APPS" | grep -qx "$app"; then
            continue
        fi

        report ask apps "the machine file lists \"$app\" and this script has no check for it"
    done

    report ok apps "every app row of the machine file has a check here"
}


check_login_items() {
    local summary

    summary=$("$SCRIPT_DIR/mac-services.sh" status 2>/dev/null | grep '^summary:')

    if [ -z "$summary" ]; then
        report ask login-items "mac-services.sh status printed no summary"
        return 0
    fi

    case "$summary" in
        *"state=done"*)
            report ok login-items "${summary#summary: }"
            ;;
        *)
            report fix login-items "${summary#summary: } — run tools/mac-services.sh turn-off"
            ;;
    esac
}


# No userland read of the Little Snitch mode exists on this machine: the
# configuration under /Library/Application Support is root-only and
# encrypted, the littlesnitch tool refuses to run without root, and the
# user preferences domain holds window state only. So the check probes
# the outcome the mode controls: can an unapproved binary reach the run
# port. A copy of node (or python3) at a fresh path is unapproved.
check_little_snitch() {
    local runner
    local tmp_dir
    local probe
    local out
    local code

    runner=$(command -v node 2>/dev/null)

    if [ -z "$runner" ]; then
        runner=$(command -v python3 2>/dev/null)
    fi

    if [ -z "$runner" ]; then
        report ask little-snitch "no node and no python3 to probe with"
        return 0
    fi

    tmp_dir=$(mktemp -d)
    probe="$tmp_dir/preflight-probe"
    cp "$runner" "$probe"
    chmod +x "$probe"

    case "$runner" in
        *python3)
            out=$("$probe" -c "
import socket, sys
s = socket.socket()
s.settimeout(4)
try:
    s.connect(('127.0.0.1', $PROBE_PORT))
    print('connect')
except ConnectionRefusedError:
    print('ECONNREFUSED')
except Exception as e:
    print(type(e).__name__)
" 2>&1)
            ;;
        *)
            out=$("$probe" -e "
const s = require('net').connect($PROBE_PORT, '127.0.0.1');
s.setTimeout(4000);
s.on('connect', () => { console.log('connect'); s.destroy(); });
s.on('timeout', () => { console.log('timeout'); s.destroy(); });
s.on('error', e => console.log(e.code));
" 2>&1)
            ;;
    esac

    code=$?
    rm -rf "$tmp_dir"

    case "$out" in
        *connect*)
            report ok little-snitch "a fresh binary path reached 127.0.0.1:$PROBE_PORT"
            ;;
        *ECONNREFUSED*)
            report ok little-snitch "port $PROBE_PORT is closed and the refusal came back: no silent deny"
            ;;
        *)
            report ask little-snitch "the probe said \"$out\" (exit $code). Little Snitch may not be in silently allow."
            ;;
    esac
}


check_wired_limit() {
    local setting
    local accepted
    local current
    local first

    setting=$(machine_setting Thresholds 'iogpu.wired_limit_mb')
    accepted="${PREFLIGHT_WIRED_LIMIT_MB:-$(numbers_in "$setting" | tr '\n' ' ')}"
    accepted=$(echo "$accepted" | awk '{ $1 = $1; print }')

    if [ -z "$(echo "$accepted" | tr -d ' ')" ]; then
        report ask wired-limit "the machine file gives no iogpu.wired_limit_mb value"
        return 0
    fi

    current=$(sysctl -n iogpu.wired_limit_mb 2>/dev/null)

    if [ -z "$current" ]; then
        report ask wired-limit "sysctl iogpu.wired_limit_mb is not readable"
        return 0
    fi

    for value in $accepted; do
        if [ "$current" = "$value" ]; then
            report ok wired-limit "$current, a value the machine file accepts"
            return 0
        fi
    done

    first=$(echo "$accepted" | awk '{ print $1 }')
    report fix wired-limit "reads $current, machine file says $accepted. Run: sudo sysctl iogpu.wired_limit_mb=$first"
}


check_memory() {
    local page_size
    local wired_mb
    local free_mb
    local swap_line
    local swap_used_mb
    local balloon_setting
    local balloon_mb

    page_size=$(sysctl -n hw.pagesize 2>/dev/null)
    swap_line=$(sysctl -n vm.swapusage 2>/dev/null)

    if [ -z "$page_size" ] || [ -z "$swap_line" ]; then
        report ask memory "sysctl gave no page size or no swap usage"
        return 0
    fi

    wired_mb=$(vm_stat | awk -v p="$page_size" '/Pages wired down/ { gsub(/\./, "", $NF); print int($NF * p / 1048576) }')
    free_mb=$(vm_stat | awk -v p="$page_size" '
        /Pages free/        { gsub(/\./, "", $NF); f = $NF }
        /Pages inactive/    { gsub(/\./, "", $NF); i = $NF }
        /Pages speculative/ { gsub(/\./, "", $NF); s = $NF }
        END { print int((f + i + s) * p / 1048576) }')
    swap_used_mb=$(echo "$swap_line" | awk '{ for (n = 1; n <= NF; n++) if ($n == "used") { gsub(/M/, "", $(n + 2)); print int($(n + 2)) } }')

    report ok memory "starting numbers: wired ${wired_mb} MB, free ${free_mb} MB, swap used ${swap_used_mb} MB"

    balloon_setting=$(machine_setting Thresholds 'Skip the balloon above')
    balloon_mb="${PREFLIGHT_BALLOON_FREE_MB:-$(numbers_in "$balloon_setting" | head -1)}"

    if echo "$balloon_setting" | grep -qi 'GB'; then
        if [ -z "${PREFLIGHT_BALLOON_FREE_MB:-}" ]; then
            balloon_mb=$((balloon_mb * 1024))
        fi
    fi

    if [ -z "$balloon_mb" ]; then
        report ask memory "the machine file gives no balloon threshold"
        return 0
    fi

    if [ "$free_mb" -ge "$balloon_mb" ]; then
        report ok memory "free is above the ${balloon_mb} MB threshold: no balloon"
    else
        report ok memory "free is below the ${balloon_mb} MB threshold: balloon needed"
    fi

    if [ -f "$START_WIRED_FILE" ]; then
        local start_wired
        start_wired=$(numbers_in "$(cat "$START_WIRED_FILE")" | head -1)

        if [ -n "$start_wired" ] && [ "$wired_mb" -gt "$start_wired" ]; then
            add_reboot_reason "wired is ${wired_mb} MB, above the recorded start value ${start_wired} MB"
        fi
    fi
}


check_reboot() {
    local target
    local still_running

    if [ -s "$STATE_FILE" ]; then
        still_running=""

        while read -r target; do
            if launchctl print "$target" 2>/dev/null | grep -q 'pid = '; then
                still_running="$still_running $target"
            fi
        done < "$STATE_FILE"

        if [ -n "$still_running" ]; then
            add_reboot_reason "a disabled item still runs:$still_running"
        fi
    fi

    if [ -z "$reboot_reasons" ]; then
        report ok reboot "no reboot condition holds"
        return 0
    fi

    echo "$reboot_reasons" | grep -v '^$' | while read -r reason; do
        printf '%-4s %-14s %s\n' fix reboot "$reason"
    done

    exit_code=1
}


case "${1:-}" in
    --help|-h)
        usage
        exit 0
        ;;
    "")
        ;;
    *)
        usage
        exit 1
        ;;
esac

check_gpu_free
check_apps
check_login_items
check_little_snitch
check_wired_limit
check_memory
check_reboot

exit "$exit_code"
