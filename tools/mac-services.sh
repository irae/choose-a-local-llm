#!/bin/bash
#
# mac-services.sh turn-off  — disable background services before a run.
# mac-services.sh restore   — put them back.
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
    *)
        echo "usage: $0 turn-off|restore"
        echo "config: $CONFIG_DIR"
        exit 1
        ;;
esac
