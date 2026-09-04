#!/bin/bash
#
# archive-evidence.sh — copy a benchmark run's session logs somewhere they
# will survive, outside any repo's gitignored scratch directory.
#
# Why this exists: 17 local Mendel rows have only 8 session logs. The other
# 9 cannot be audited, defended or reproduced, because their logs lived in
# a gitignored `scratchpad/` and went away with the worktree. A row whose
# evidence is gone is a number nobody can check.
#
# Where it copies to, and why not the cache directory: a cache is defined
# as safe to delete. This evidence is not — losing it destroys the only
# proof behind a published measurement. The XDG category for user data
# that must persist is the data directory, so that is what this uses:
#
#   $XDG_DATA_HOME, or ~/.local/share when unset
#     choose-a-local-llm/evidence/<run-slug>/
#
# Use ~/.cache/choose-a-local-llm/ only for things that can be rebuilt.
#
# It also picks up pi's own session transcripts from any `.pi-agent-*`
# directory under the source, which is where an aborted run's only
# evidence lives when no result row was ever written.
#
# Usage:
#   archive-evidence.sh <source-dir> [run-slug]
#   archive-evidence.sh --list

set -u

DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
EVIDENCE_DIR="$DATA_HOME/choose-a-local-llm/evidence"


show_list() {
    if [ ! -d "$EVIDENCE_DIR" ]; then
        echo "Nothing archived yet. Would use: $EVIDENCE_DIR"
        return 0
    fi

    echo "Archived runs in $EVIDENCE_DIR"
    for dir in "$EVIDENCE_DIR"/*/; do
        [ -d "$dir" ] || continue
        local count
        count=$(find "$dir" -type f | wc -l | tr -d ' ')
        local size
        size=$(du -sh "$dir" | cut -f1)
        printf "  %-52s %4s files  %6s\n" "$(basename "$dir")" "$count" "$size"
    done
}


copy_evidence() {
    local source="$1"
    local slug="$2"
    local target="$EVIDENCE_DIR/$slug"

    if [ ! -d "$source" ]; then
        echo "No such directory: $source"
        exit 1
    fi

    mkdir -p "$target"

    local copied=0
    for pattern in '*-session.jsonl' '*-events.jsonl' '*-meta.json' \
                   '*-worker.json' '*-runner.log' '*-plan-*.json' \
                   '*-evidence.json' '*-session.html'; do
        for file in "$source"/$pattern; do
            [ -f "$file" ] || continue
            cp -p "$file" "$target/"
            copied=$(( copied + 1 ))
        done
    done

    for probe_dir in "$source"/session-*; do
        [ -d "$probe_dir" ] || continue
        local probe_name
        probe_name=$(basename "$probe_dir")
        mkdir -p "$target/$probe_name"
        while IFS= read -r file; do
            cp -p "$file" "$target/$probe_name/"
            copied=$(( copied + 1 ))
        done < <(find "$probe_dir" -name '*.jsonl' -type f)
    done

    for extra in "$source"/out-*.txt "$source"/server-*.log "$source"/*.log; do
        [ -f "$extra" ] || continue
        cp -p "$extra" "$target/"
        copied=$(( copied + 1 ))
    done

    for agent_dir in "$source"/.pi-agent-*; do
        [ -d "$agent_dir" ] || continue
        local name
        name=$(basename "$agent_dir")
        mkdir -p "$target/$name"
        while IFS= read -r file; do
            cp -p "$file" "$target/$name/"
            copied=$(( copied + 1 ))
        done < <(find "$agent_dir" -name '*.jsonl' -type f)
    done

    if [ "$copied" -eq 0 ]; then
        echo "Found nothing to archive in $source"
        rmdir "$target" 2>/dev/null
        exit 1
    fi

    date -u +"archived %Y-%m-%dT%H:%M:%SZ" > "$target/ARCHIVED"
    echo "from $source" >> "$target/ARCHIVED"

    echo "Archived $copied files to $target"
}


case "${1:-}" in
    --list)
        show_list
        ;;
    "")
        echo "usage: $0 <source-dir> [run-slug]"
        echo "       $0 --list"
        echo "store: $EVIDENCE_DIR"
        exit 1
        ;;
    *)
        SOURCE="$1"
        SLUG="${2:-$(date -u +%Y%m%d)-$(basename "$(dirname "$SOURCE")")}"
        copy_evidence "$SOURCE" "$SLUG"
        ;;
esac
