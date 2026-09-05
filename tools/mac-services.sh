#!/bin/bash
#
# mac-services.sh turn-off  — disable background services before a run.
# mac-services.sh restore   — put them back.
# mac-services.sh status    — read only. Says what is off already.
#
# The verbs say what happens to the SERVICES. An earlier version used
# "off" and "on", which read as a mode: "quiet mode on" sounded like it
# would switch things on, when it switches them off.
#
# The lists of what to disable are NOT in this repo. They describe one
# person's Mac. They live in the config directory below. Read
# tools/README-mac-quiet.md to learn how to build them for your machine.
#
# Every label this script disables is written to the state file. "on" reads
# that file, so it can never re-enable something you disabled by hand.
#
# Both directions need a reboot to take effect.
#
# "status" changes nothing. It prints the launchd state of every label in
# the config files and ends with one summary line that tools/preflight.sh
# reads.

set -u

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/choose-a-local-llm"
USER_AGENTS_FILE="$CONFIG_DIR/services-user-agents.conf"
SYSTEM_DAEMONS_FILE="$CONFIG_DIR/services-system-daemons.conf"
STATE_FILE="$CONFIG_DIR/services-state"


# Strips comments and blank lines. Prints one label per line.
read_labels() {
    local file="$1"

    if [ ! -f "$file" ]; then
        return 0
    fi

    sed 's/#.*//' "$file" | tr -d ' \t' | grep -v '^$'
}


require_config() {
    if [ -f "$USER_AGENTS_FILE" ]; then
        return 0
    fi

    if [ -f "$SYSTEM_DAEMONS_FILE" ]; then
        return 0
    fi

    echo "No config found in $CONFIG_DIR"
    echo "Expected services-user-agents.conf or services-system-daemons.conf."
    echo "See tools/README-mac-quiet.md for how to build them."
    exit 1
}


disable_user_agent() {
    local label="$1"
    local target="gui/$UID/$label"

    if launchctl disable "$target"; then
        echo "$target" >> "$STATE_FILE"
        echo "  disabled  $label"
    else
        echo "  SKIPPED   $label (not found)"
    fi
}


disable_system_daemon() {
    local label="$1"
    local target="system/$label"

    if sudo launchctl disable "$target"; then
        echo "$target" >> "$STATE_FILE"
        echo "  disabled  $label"
    else
        echo "  SKIPPED   $label (not found)"
    fi
}


enable_one() {
    local target="$1"

    case "$target" in
        system/*)
            sudo launchctl enable "$target"
            ;;
        *)
            launchctl enable "$target"
            ;;
    esac

    echo "  restored  $target"
}


# Desktop widgets only: com.apple.WindowManager StandardHideWidgets.
# Both directions work headlessly, which is the bar for anything in this
# script — a setting it can turn off but not turn back on would leave the
# machine worse than it found it.
#
# iPhone widgets are deliberately NOT touched: they can be switched off
# from a script but only switched back on from System Settings, and a
# one-way setting does not belong here.
#
# This never writes the widget LAYOUT, which lives in the chronod
# database.
hide_widgets() {
    defaults write com.apple.WindowManager StandardHideWidgets -bool true
    killall WindowManager
    echo "  desktop widgets hidden"
}


restore_widgets() {
    defaults write com.apple.WindowManager StandardHideWidgets -bool false
    killall WindowManager
    echo "  desktop widgets shown"
}


# Called when "restore" has no state file. Says what the widget setting is
# and how to change it, instead of exiting with nothing done — it can be
# changed by hand, and then this script has no record.
report_widget_state() {
    local desktop_hidden
    desktop_hidden=$(defaults read com.apple.WindowManager StandardHideWidgets 2>/dev/null || echo 0)

    if [ "$desktop_hidden" = "1" ]; then
        echo "  desktop widgets are HIDDEN. To show them:"
        echo "    defaults write com.apple.WindowManager StandardHideWidgets -bool false && killall WindowManager"
    else
        echo "  desktop widgets are shown"
    fi
}


# Read only. Prints the launchd state of every configured label, the
# widget setting, and one "summary:" line for tools/preflight.sh.
# "state=done" means turn-off already ran, so a run must not run it again.
label_state() {
    local target="$1"
    local line

    line=$(launchctl print-disabled "${target%/*}" 2>/dev/null | grep "\"${target##*/}\" =>")

    case "$line" in
        *disabled*) echo "disabled" ;;
        *enabled*)  echo "enabled" ;;
        *)          echo "unknown" ;;
    esac
}


status() {
    local recorded=0
    local drifted=0
    local drifted_labels=""
    local state
    local target

    echo "User agents:"
    for label in $(read_labels "$USER_AGENTS_FILE"); do
        echo "  $(label_state "gui/$UID/$label")  $label"
    done

    echo "System daemons:"
    for label in $(read_labels "$SYSTEM_DAEMONS_FILE"); do
        echo "  $(label_state "system/$label")  $label"
    done

    echo "Widgets:"
    report_widget_state

    echo "State file:"
    if [ -s "$STATE_FILE" ]; then
        recorded=$(grep -c . "$STATE_FILE")
        echo "  $STATE_FILE records $recorded items"
    else
        echo "  no state file, so this script disabled nothing"
    fi

    if [ -s "$STATE_FILE" ]; then
        while read -r target; do
            state=$(label_state "$target")

            if [ "$state" = "disabled" ]; then
                continue
            fi

            drifted=$((drifted + 1))
            drifted_labels="$drifted_labels ${target##*/}"
        done < "$STATE_FILE"
    fi

    echo
    if [ -s "$STATE_FILE" ]; then
        echo "summary: state=done recorded=$recorded drifted=$drifted$drifted_labels"
        exit 0
    fi

    echo "summary: state=not-done recorded=0 drifted=0"
    exit 1
}


turn_off() {
    require_config

    if [ -s "$STATE_FILE" ]; then
        echo "Already turned off. Run '$0 restore' first."
        exit 1
    fi

    : > "$STATE_FILE"

    echo "User agents:"
    for label in $(read_labels "$USER_AGENTS_FILE"); do
        disable_user_agent "$label"
    done

    echo "System daemons:"
    for label in $(read_labels "$SYSTEM_DAEMONS_FILE"); do
        disable_system_daemon "$label"
    done

    echo "Widgets:"
    hide_widgets

    echo
    echo "Disabled $(wc -l < "$STATE_FILE" | tr -d ' ') items. Reboot to take effect."
}


turn_on() {
    if [ ! -s "$STATE_FILE" ]; then
        echo "No state file, so this script disabled no launchd items."
        echo "Widgets can be changed outside this script, so checking them:"
        report_widget_state
        exit 0
    fi

    echo "Restoring:"
    while read -r target; do
        case "$target" in
            widget:*) continue ;;
        esac
        enable_one "$target"
    done < "$STATE_FILE"

    echo "Widgets:"
    restore_widgets

    rm "$STATE_FILE"

    echo
    echo "Restored. Reboot to take effect."
}


case "${1:-}" in
    turn-off)
        turn_off
        ;;
    restore)
        turn_on
        ;;
    status)
        status
        ;;
    *)
        echo "usage: $0 turn-off|restore|status"
        echo "config: $CONFIG_DIR"
        exit 1
        ;;
esac
