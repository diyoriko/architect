#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHITECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SAMI_DIR="${SAMI_PROJECT_DIR:-$HOME/Documents/Projects/Sami}"
HUNTER_DIR="${HUNTER_PROJECT_DIR:-$HOME/Documents/Projects/Hunter}"
REPORT_DIR="$ARCHITECT_DIR/code-reviews"
DATE=$(date +%Y-%m-%d)
REPORT_FILE="$REPORT_DIR/$DATE.md"
TMP_PROMPT=$(mktemp)

# Telegram config
BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
if [ -z "$BOT_TOKEN" ] && [ -f "$SAMI_DIR/agents/community/.env" ]; then
  BOT_TOKEN=$(grep TELEGRAM_BOT_TOKEN "$SAMI_DIR/agents/community/.env" | cut -d= -f2)
fi
ADMIN_CHAT_ID="${TELEGRAM_ADMIN_USER_ID:-85013206}"

# PATH for claude CLI
if [ -d "$HOME/.nvm/versions/node" ]; then
  NVM_BIN=$(ls -d "$HOME"/.nvm/versions/node/*/bin 2>/dev/null | tail -1)
  export PATH="$HOME/.local/bin:${NVM_BIN:-}:/usr/local/bin:/usr/bin:/bin:$PATH"
fi

unset CLAUDECODE 2>/dev/null || true

cleanup() { rm -f "$TMP_PROMPT"; }
trap cleanup EXIT

mkdir -p "$REPORT_DIR"

if [ -f "$REPORT_FILE" ]; then
  echo "Code review for $DATE already exists, skipping"
  exit 0
fi

echo "$(date -Iseconds) Starting code review..."

# Build prompt with actual code
{
  cat "$SCRIPT_DIR/prompt.md"
  echo ""
  echo "---"
  echo "Дата: $DATE"
  echo ""

  # SAMI source code (key files)
  echo "=== SAMI: src/ files ==="
  for f in "$SAMI_DIR"/agents/community/src/*.ts; do
    name=$(basename "$f")
    lines=$(wc -l < "$f")
    echo "--- $name ($lines lines) ---"
    if [ "$lines" -gt 800 ]; then
      # Large files: show structure only
      grep -n "^export function\|^export class\|^export const\|^function " "$f" || true
    else
      cat "$f"
    fi
    echo ""
  done

  # Hunter source code (key files)
  echo "=== HUNTER: src/ files ==="
  for f in "$HUNTER_DIR"/src/*.ts; do
    name=$(basename "$f")
    [[ "$name" == *.test.ts ]] && continue
    [[ "$name" == *.d.ts ]] && continue
    lines=$(wc -l < "$f")
    echo "--- $name ($lines lines) ---"
    if [ "$lines" -gt 800 ]; then
      grep -n "^export function\|^export class\|^export const\|^function " "$f" || true
    else
      cat "$f"
    fi
    echo ""
  done

  # Hunter scrapers
  echo "=== HUNTER: scrapers/ ==="
  for f in "$HUNTER_DIR"/src/scrapers/*.ts; do
    name=$(basename "$f")
    [[ "$name" == *.test.ts ]] && continue
    echo "--- scrapers/$name ---"
    cat "$f"
    echo ""
  done

  # Previous code review for continuity
  LAST_REVIEW=$(ls -t "$REPORT_DIR"/*.md 2>/dev/null | head -1 || true)
  if [ -n "$LAST_REVIEW" ] && [ "$LAST_REVIEW" != "$REPORT_FILE" ]; then
    echo "=== Previous code review ==="
    head -40 "$LAST_REVIEW"
  fi

  echo ""
  echo "---"
  echo "Сделай code review. Следуй формату из промпта. Будь конкретным: файл:строка."
} > "$TMP_PROMPT"

# Run Claude
echo "$(date -Iseconds) Running Claude analysis..."
if ! REPORT=$(claude --print --model claude-sonnet-4-6 < "$TMP_PROMPT" 2>&1); then
  echo "$(date -Iseconds) Claude failed: $REPORT"
  exit 1
fi

echo "$REPORT" > "$REPORT_FILE"
echo "$(date -Iseconds) Review saved to $REPORT_FILE"

# Telegram notification
PREVIEW=$(echo "$REPORT" | head -25)
NOTIFY_TEXT="Code Review — $DATE

${PREVIEW}

...полный отчёт в Architect/code-reviews/$DATE.md"
NOTIFY_TEXT="${NOTIFY_TEXT:0:4000}"

if [ -n "$BOT_TOKEN" ]; then
  curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d "chat_id=${ADMIN_CHAT_ID}" \
    -d "disable_web_page_preview=true" \
    --data-urlencode "text=${NOTIFY_TEXT}" \
    > /dev/null 2>&1 || echo "$(date -Iseconds) Telegram notification failed"
fi

# Google Calendar event
CRITICAL=$(echo "$REPORT" | grep -c "critical\|Critical\|CRITICAL" || true)
SUMMARY="Code Review: ${CRITICAL} critical issues"
if command -v gcalcli >/dev/null 2>&1; then
  ITEMS=$(echo "$REPORT" | grep -A 10 "## Action Items" | grep "^[0-9]\." | head -5 | tr '\n' ' ' | cut -c1-200)
  gcalcli add \
    --calendar "Personal" \
    --title "Code Review — $DATE" \
    --when "$(date -v+1H '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')" \
    --duration 15 \
    --description "${ITEMS:-No critical issues}" \
    --noprompt 2>/dev/null && echo "$(date -Iseconds) Google Calendar event created" \
    || echo "$(date -Iseconds) Google Calendar event failed (non-critical)"
fi

echo "$(date -Iseconds) Code review complete"
