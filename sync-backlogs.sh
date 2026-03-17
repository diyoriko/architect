#!/usr/bin/env bash
# Sync project backlogs to Architect repo for live dashboard
# Runs every 5 min via launchd

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAMI_DIR="${SAMI_PROJECT_DIR:-$HOME/Documents/Projects/Sami}"
HUNTER_DIR="${HUNTER_PROJECT_DIR:-$HOME/Documents/Projects/Hunter}"

CHANGED=0

# Copy if different
sync_file() {
  local src="$1" dst="$2"
  if [ -f "$src" ]; then
    if ! cmp -s "$src" "$dst" 2>/dev/null; then
      cp "$src" "$dst"
      CHANGED=1
    fi
  fi
}

sync_file "$HUNTER_DIR/BACKLOG.md" "$SCRIPT_DIR/hunter-BACKLOG.md"
sync_file "$SAMI_DIR/COMMUNITY_TASKS.md" "$SCRIPT_DIR/sami-BACKLOG.md"

if [ "$CHANGED" -eq 1 ] && cd "$SCRIPT_DIR" && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git add hunter-BACKLOG.md sami-BACKLOG.md 2>/dev/null
  if ! git diff --cached --quiet 2>/dev/null; then
    git commit -m "sync: backlogs updated $(date +%H:%M)" 2>/dev/null
    git push origin main 2>/dev/null
  fi
fi
