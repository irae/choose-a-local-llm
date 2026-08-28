#!/usr/bin/env bash
# Build the site, verify it, and commit. Stops before pushing.
# master is never touched by this script — the push is the owner's to run.
#
# Usage:  ./scripts/publish.sh "what changed"
#         ./scripts/publish.sh            (only if the tree is already clean)
set -euo pipefail

cd "$(dirname "$0")/.."

REPO="irae/choose-a-local-llm"
URL="https://irae.github.io/choose-a-local-llm/"

say()  { printf '\n\033[1m==> %s\033[0m\n' "$1"; }
warn() { printf '\033[33m%s\033[0m\n' "$1"; }
die()  { printf '\n\033[31mERROR: %s\033[0m\n' "$1" >&2; exit 1; }

say "Building"
npm run docs:build

say "Checking links"
npm run docs:check

if [ -n "$(git status --porcelain)" ]; then
  if [ $# -lt 1 ] || [ -z "$1" ]; then
    git status --short
    die "Uncommitted changes. Give a commit message: ./scripts/publish.sh \"what changed\""
  fi
  say "Committing"
  git add -A
  git commit -q -m "$1"
else
  say "Nothing to commit"
fi

BRANCH="$(git branch --show-current)"

say "Checking the GitHub Pages source"
if command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
  BUILD_TYPE="$(gh api "repos/$REPO/pages" --jq .build_type 2>/dev/null || echo "")"
  if [ "$BUILD_TYPE" = "workflow" ]; then
    echo "Pages already builds from GitHub Actions."
  else
    warn "Pages is not set to build from GitHub Actions yet."
    warn "Run this once (it changes repo settings, so it is yours to run):"
    warn "    gh api -X POST repos/$REPO/pages -f build_type=workflow"
  fi
else
  warn "gh not available; cannot check the Pages source."
fi

cat <<EOF

$(printf '\033[1m==> Ready. Nothing has been pushed.\033[0m')

Branch '$BRANCH' is built and verified. To publish, push it to master
yourself, when the other agent is not mid-run:

    git push origin $BRANCH:master

That updates origin/master only. Your local master and its worktree are
not touched, so the other agent keeps working undisturbed.

Then watch the deploy:

    gh run watch \$(gh run list --workflow=site.yml --limit 1 --json databaseId --jq '.[0].databaseId') --exit-status

The site lands at:
    $URL
EOF
