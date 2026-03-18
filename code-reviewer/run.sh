#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHITECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SAMI_DIR="${SAMI_PROJECT_DIR:-$HOME/Documents/Projects/Sami}"
HUNTER_DIR="${HUNTER_PROJECT_DIR:-$HOME/Documents/Projects/Hunter}"
PORTFOLIO_DIR="${PORTFOLIO_PROJECT_DIR:-$HOME/Documents/Projects/Portfolio}"
VEDIC_DIR="${VEDIC_PROJECT_DIR:-$HOME/Documents/Projects/Vedic Turkey}"
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

  # Portfolio source code (HTML + JS + CSS)
  echo "=== PORTFOLIO: site/ files ==="
  for f in "$PORTFOLIO_DIR"/site/index.html "$PORTFOLIO_DIR"/site/about.html "$PORTFOLIO_DIR"/site/script.js "$PORTFOLIO_DIR"/site/styles.css; do
    if [ -f "$f" ]; then
      name=$(basename "$f")
      lines=$(wc -l < "$f")
      echo "--- $name ($lines lines) ---"
      cat "$f"
      echo ""
    fi
  done
  # Portfolio project pages (sample)
  for f in "$PORTFOLIO_DIR"/site/projects/*.html; do
    if [ -f "$f" ]; then
      name=$(basename "$f")
      lines=$(wc -l < "$f")
      echo "--- projects/$name ($lines lines) ---"
      if [ "$lines" -gt 500 ]; then
        head -50 "$f"
        echo "... (truncated)"
      else
        cat "$f"
      fi
      echo ""
    fi
  done

  # Vedic Turkiye source code (Next.js)
  echo "=== VEDIC TURKIYE: src/lib/ ==="
  for f in "$VEDIC_DIR"/src/lib/**/*.ts; do
    if [ -f "$f" ]; then
      name=${f#"$VEDIC_DIR"/src/}
      lines=$(wc -l < "$f")
      echo "--- $name ($lines lines) ---"
      if [ "$lines" -gt 800 ]; then
        grep -n "^export function\|^export class\|^export const\|^function " "$f" || true
      else
        cat "$f"
      fi
      echo ""
    fi
  done

  echo "=== VEDIC TURKIYE: src/components/ ==="
  for f in "$VEDIC_DIR"/src/components/**/*.tsx; do
    if [ -f "$f" ]; then
      name=${f#"$VEDIC_DIR"/src/}
      lines=$(wc -l < "$f")
      echo "--- $name ($lines lines) ---"
      if [ "$lines" -gt 800 ]; then
        grep -n "^export function\|^export class\|^export const\|^function " "$f" || true
      else
        cat "$f"
      fi
      echo ""
    fi
  done

  echo "=== VEDIC TURKIYE: src/app/api/ ==="
  for f in "$VEDIC_DIR"/src/app/api/**/*.ts; do
    if [ -f "$f" ]; then
      name=${f#"$VEDIC_DIR"/src/}
      lines=$(wc -l < "$f")
      echo "--- $name ($lines lines) ---"
      cat "$f"
      echo ""
    fi
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

# No Telegram — only Google Calendar (less noise)

# Extract action items and append to project backlogs
echo "$(date -Iseconds) Syncing action items to project backlogs..."

SAMI_ITEMS=$(echo "$REPORT" | grep -E "SAMI|sami" | grep -E "approval|shared|db\.|index\.|analytics|scheduler|notify|rubrics|config" | head -5 | sed 's/^[0-9]*\. /- [ ] **Code Review:** /' | sed 's/|.*|/—/')
HUNTER_ITEMS=$(echo "$REPORT" | grep -E "Hunter|hunter|Ловец" | grep -E "bot\.|db\.|config\.|scorer|cover-letter|index|scrapers" | head -5 | sed 's/^[0-9]*\. /- [ ] **Code Review:** /' | sed 's/|.*|/—/')
VEDIC_ITEMS=$(echo "$REPORT" | grep -E "Vedic|vedic|Vedik|vedik|Turkiye|Jyotish" | grep -E "calculate\|interpret\|shopier\|chart\|api/\|landing\|geocode\|pdf\|brevo" | head -5 | sed 's/^[0-9]*\. /- [ ] **Code Review:** /' | sed 's/|.*|/—/')
PORTFOLIO_ITEMS=$(echo "$REPORT" | grep -E "Portfolio|portfolio|diyor\.design" | grep -E "script\|styles\|index\|about\|projects/" | head -5 | sed 's/^[0-9]*\. /- [ ] **Code Review:** /' | sed 's/|.*|/—/')

if [ -n "$SAMI_ITEMS" ]; then
  TASKS_FILE="$SAMI_DIR/COMMUNITY_TASKS.md"
  if [ -f "$TASKS_FILE" ] && ! grep -q "Code Review: $DATE" "$TASKS_FILE" 2>/dev/null; then
    echo "" >> "$TASKS_FILE"
    echo "### Code Review $DATE" >> "$TASKS_FILE"
    echo "$SAMI_ITEMS" >> "$TASKS_FILE"
    echo "$(date -Iseconds) SAMI backlog updated with code review items"
  fi
fi

if [ -n "$HUNTER_ITEMS" ]; then
  TASKS_FILE="$HUNTER_DIR/BACKLOG.md"
  if [ -f "$TASKS_FILE" ] && ! grep -q "Code Review: $DATE" "$TASKS_FILE" 2>/dev/null; then
    echo "" >> "$TASKS_FILE"
    echo "### Code Review $DATE" >> "$TASKS_FILE"
    echo "$HUNTER_ITEMS" >> "$TASKS_FILE"
    echo "$(date -Iseconds) Hunter backlog updated with code review items"
  fi
fi

if [ -n "$VEDIC_ITEMS" ]; then
  TASKS_FILE="$VEDIC_DIR/BACKLOG.md"
  if [ -f "$TASKS_FILE" ] && ! grep -q "Code Review: $DATE" "$TASKS_FILE" 2>/dev/null; then
    echo "" >> "$TASKS_FILE"
    echo "### Code Review $DATE" >> "$TASKS_FILE"
    echo "$VEDIC_ITEMS" >> "$TASKS_FILE"
    echo "$(date -Iseconds) Vedic Turkiye backlog updated with code review items"
  fi
fi

if [ -n "$PORTFOLIO_ITEMS" ]; then
  TASKS_FILE="$PORTFOLIO_DIR/BACKLOG.md"
  if [ -f "$TASKS_FILE" ] && ! grep -q "Code Review: $DATE" "$TASKS_FILE" 2>/dev/null; then
    echo "" >> "$TASKS_FILE"
    echo "### Code Review $DATE" >> "$TASKS_FILE"
    echo "$PORTFOLIO_ITEMS" >> "$TASKS_FILE"
    echo "$(date -Iseconds) Portfolio backlog updated with code review items"
  fi
fi

# Google Calendar event
CRITICAL=$(echo "$REPORT" | grep -c "critical\|Critical\|CRITICAL" || true)
SUMMARY="Code Review: ${CRITICAL} critical issues"
if command -v gcalcli >/dev/null 2>&1; then
  SUMMARY=$(echo "$REPORT" | head -5 | tail -3 | sed 's/\*\*//g' | sed 's/`//g' | sed 's/^#\+ //' | tr '\n' ' ' | cut -c1-150)
  ITEMS=$(echo "$REPORT" | grep -A 10 "## Action Items" | grep "^[0-9]\." | head -5 | sed 's/\*\*//g' | sed 's/`//g' | tr '\n' '\n')
  DESC="$(printf '%s\n\n%s\n\nReport: ~/Documents/Projects/Architect/code-reviews/%s.md' "$SUMMARY" "$ITEMS" "$DATE")"
  gcalcli add \
    --calendar "Personal" \
    --title "Mega Review — $DATE ($CRITICAL critical)" \
    --when "$(date -v+1H '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')" \
    --duration 15 \
    --description "$DESC" \
    --noprompt 2>/dev/null && echo "$(date -Iseconds) Google Calendar event created" \
    || echo "$(date -Iseconds) Google Calendar event failed (non-critical)"
fi

echo "$(date -Iseconds) Code review complete"
