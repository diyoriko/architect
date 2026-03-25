#!/bin/bash
# Auto-save session state after git commit
# Called by Claude Code PostToolUse hook on Bash commands containing "git commit"

INPUT=$(cat)

# Only trigger on git commit commands
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)
echo "$CMD" | grep -q "git commit" || exit 0

# Extract info
PROJECT_DIR=$(echo "$INPUT" | jq -r '.session_cwd // ""' 2>/dev/null)
PROJECT_NAME=$(basename "$PROJECT_DIR" 2>/dev/null || echo "unknown")
COMMIT_HASH=$(git -C "$PROJECT_DIR" log -1 --format="%h" 2>/dev/null || echo "?")
COMMIT_MSG=$(git -C "$PROJECT_DIR" log -1 --format="%s" 2>/dev/null || echo "?")
DATE=$(date +%Y-%m-%d\ %H:%M)

SESSION_FILE="$HOME/.claude/projects/-Users-diyoriko/memory/session_current.md"

cat > "$SESSION_FILE" << EOF
---
name: session_current
description: Auto-saved session state (updated on every git commit)
type: project
---

## Last Activity: $DATE

**Project:** $PROJECT_NAME ($PROJECT_DIR)
**Last commit:** $COMMIT_HASH — $COMMIT_MSG
**Status:** in progress
EOF
