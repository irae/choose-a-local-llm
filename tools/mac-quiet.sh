#!/bin/bash
#
# mac-quiet.sh off  — disable background login items before a benchmark run.
# mac-quiet.sh on   — put back exactly what "off" disabled.
#
# The lists of what to disable are NOT in this repo. They describe one
# person's Mac. They live in the config directory below. Read
# tools/README-mac-quiet.md to learn how to build them for your machine.
#
# Every label this script disables is written to the state file. "on" reads
# that file, so it can never re-enable something you disabled by hand.
#
# Both directions need a reboot to take effect.

set -u

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/choose-a-local-llm"
USER_AGENTS_FILE="$CONFIG_DIR/quiet-user-agents.conf"
SYSTEM_DAEMONS_FILE="$CONFIG_DIR/quiet-system-daemons.conf"
STATE_FILE="$CONFIG_DIR/quiet-state"


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
    echo "Expected quiet-user-agents.conf or quiet-system-daemons.conf."
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


hide_widgets() {
    defaults write com.apple.WindowManager StandardHideWidgets -bool true
    killall WindowManager
    echo "  widgets hidden"
}


show_widgets() {
    defaults write com.apple.WindowManager StandardHideWidgets -bool false
    killall WindowManager
    echo "  widgets shown"
}


turn_off() {
    require_config

    if [ -s "$STATE_FILE" ]; then
        echo "Already off. Run '$0 on' first."
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
        echo "Nothing to restore. $STATE_FILE is empty or missing."
        exit 1
    fi

    echo "Restoring:"
    while read -r target; do
        enable_one "$target"
    done < "$STATE_FILE"

    echo "Widgets:"
    show_widgets

    rm "$STATE_FILE"

    echo
    echo "Restored. Reboot to take effect."
}


case "${1:-}" in
    off)
        turn_off
        ;;
    on)
        turn_on
        ;;
    *)
        echo "usage: $0 off|on"
        echo "config: $CONFIG_DIR"
        exit 1
        ;;
esac
