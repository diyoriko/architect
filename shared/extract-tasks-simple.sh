#!/bin/bash
# Extract new tasks from strategist report and add directly to backlog
# Simplified version for projects without bot (Portfolio, Vedic)
# Usage: extract-tasks-simple.sh <report_file> <backlog_file> [bot_token] [chat_id]

set -euo pipefail

REPORT_FILE="$1"
BACKLOG_FILE="$2"
BOT_TOKEN="${3:-}"
ADMIN_CHAT_ID="${4:-}"

if [ ! -f "$REPORT_FILE" ] || [ ! -f "$BACKLOG_FILE" ]; then
  echo "Report or backlog not found"
  exit 1
fi

# Extract tasks from "Новые задачи в бэклог" section
TASKS=$(awk '
  /^## Новые задачи/ { found=1; next }
  /^## / { if(found) exit }
  /^- \[/ { if(found) print }
' "$REPORT_FILE")

if [ -z "$TASKS" ]; then
  echo "No new tasks found in report"
  exit 0
fi

DATE=$(date +%Y-%m-%d)
ADDED=0
SKIPPED=0
ADDED_LIST=""

while IFS= read -r task; do
  # Extract task name (text between ** **)
  TASK_NAME=$(echo "$task" | sed -n 's/.*\*\*\(.*\)\*\*.*/\1/p')
  [ -z "$TASK_NAME" ] && continue

  # Skip if already exists
  if grep -qF "$TASK_NAME" "$BACKLOG_FILE" 2>/dev/null; then
    echo "Skip (exists): $TASK_NAME"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Add source tag
  tagged_task="${task} \`[strategist]\`"

  # Add to backlog — find first --- separator and insert before it
  FIRST_SEP=$(grep -n '^---$' "$BACKLOG_FILE" | head -1 | cut -d: -f1)
  if [ -n "$FIRST_SEP" ] && [ "$FIRST_SEP" -gt 3 ]; then
    sed -i '' "${FIRST_SEP}i\\
${tagged_task}
" "$BACKLOG_FILE" 2>/dev/null || echo "$tagged_task" >> "$BACKLOG_FILE"
  else
    echo "$tagged_task" >> "$BACKLOG_FILE"
  fi

  echo "Added: $TASK_NAME"
  ADDED_LIST="${ADDED_LIST}\n• ${TASK_NAME}"
  ADDED=$((ADDED + 1))
done <<< "$TASKS"

echo "Added $ADDED tasks, skipped $SKIPPED duplicates"

# Telegram notification
if [ "$ADDED" -gt 0 ] && [ -n "$BOT_TOKEN" ] && [ -n "$ADMIN_CHAT_ID" ]; then
  NOTIFY="📋 Стратег добавил $ADDED задач в бэклог ($DATE):$(echo -e "$ADDED_LIST")"
  NOTIFY="${NOTIFY:0:4000}"
  curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d "chat_id=${ADMIN_CHAT_ID}" \
    --data-urlencode "text=${NOTIFY}" \
    > /dev/null 2>&1 || true
fi
