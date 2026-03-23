#!/usr/bin/env bash
set -euo pipefail

# Agent Health Watchdog
# Checks all launchd agents have produced recent reports.
# Sends Telegram alert only when something is overdue.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATE=$(date +%Y-%m-%d)

# Project directories
HUNTER_DIR="${HUNTER_PROJECT_DIR:-$HOME/Documents/Projects/Hunter}"
SAMI_DIR="${SAMI_PROJECT_DIR:-$HOME/Documents/Projects/Sami}"
PORTFOLIO_DIR="${PORTFOLIO_PROJECT_DIR:-$HOME/Documents/Projects/Portfolio}"
VEDIC_DIR="${VEDIC_PROJECT_DIR:-$HOME/Documents/Projects/Vedic Turkey}"
ARCHITECT_DIR="$SCRIPT_DIR"

# Telegram config — borrow SAMI bot token
BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
if [ -z "$BOT_TOKEN" ] && [ -f "$SAMI_DIR/agents/community/.env" ]; then
  BOT_TOKEN=$(grep TELEGRAM_BOT_TOKEN "$SAMI_DIR/agents/community/.env" | cut -d= -f2)
fi
ADMIN_CHAT_ID="${TELEGRAM_ADMIN_USER_ID:-85013206}"

send_telegram() {
  local message="$1"
  if [ -z "$BOT_TOKEN" ]; then
    echo "$(date -Iseconds) ERROR: No Telegram bot token available, cannot send alert"
    echo "$message"
    return 1
  fi
  curl -sf --max-time 15 \
    -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d chat_id="$ADMIN_CHAT_ID" \
    -d parse_mode=Markdown \
    --data-urlencode "text=$message" >/dev/null 2>&1
}

# check_agent <name> <reports_dir> <max_hours>
# Returns 0 if healthy, 1 if overdue. Appends to OVERDUE array.
check_agent() {
  local name="$1"
  local reports_dir="$2"
  local max_hours="$3"

  if [ ! -d "$reports_dir" ]; then
    echo "  $name: reports dir missing ($reports_dir)"
    OVERDUE+=("$name — reports directory not found")
    return 1
  fi

  # Find the most recently modified .md file in the reports directory
  # Using ls + stat instead of find (macOS sandbox compatibility)
  local latest_file
  latest_file=$(ls -t "$reports_dir"/*.md 2>/dev/null | head -1 || true)

  if [ -z "$latest_file" ]; then
    echo "  $name: no report files found"
    OVERDUE+=("$name — no reports found")
    return 1
  fi

  local latest_ts
  latest_ts=$(stat -f "%m" "$latest_file" 2>/dev/null)
  if [ -z "$latest_ts" ]; then
    echo "  $name: cannot stat $latest_file"
    OVERDUE+=("$name — cannot read report timestamp")
    return 1
  fi
  local now_ts
  now_ts=$(date +%s)
  local age_hours=$(( (now_ts - latest_ts) / 3600 ))

  if [ "$age_hours" -gt "$max_hours" ]; then
    echo "  $name: OVERDUE (${age_hours}h ago, threshold ${max_hours}h) — $(basename "$latest_file")"
    OVERDUE+=("$name — last report ${age_hours}h ago (limit: ${max_hours}h)")
    return 1
  else
    echo "  $name: OK (${age_hours}h ago) — $(basename "$latest_file")"
    return 0
  fi
}

echo "$(date -Iseconds) Agent Health Watchdog starting..."
echo ""

OVERDUE=()

# Daily agents (threshold: 26 hours)
echo "=== Daily Agents ==="
check_agent "Hunter Strategist" "$HUNTER_DIR/reports/strategist" 26 || true

echo ""

# Weekly agents (threshold: 8 days = 192 hours)
echo "=== Weekly Agents ==="
check_agent "SAMI Strategist"      "$SAMI_DIR/reports/strategist"        192 || true
check_agent "Portfolio Strategist"  "$PORTFOLIO_DIR/reports/strategist"   192 || true
check_agent "Vedic Strategist"     "$VEDIC_DIR/reports/strategist"       192 || true
check_agent "Architect"            "$ARCHITECT_DIR/reports"              192 || true
check_agent "Mega Reviewer"        "$ARCHITECT_DIR/code-reviews"         192 || true

echo ""

# Verdict
if [ ${#OVERDUE[@]} -eq 0 ]; then
  echo "$(date -Iseconds) All agents healthy. No alert needed."
  exit 0
fi

echo "$(date -Iseconds) ${#OVERDUE[@]} agent(s) overdue. Sending Telegram alert..."

# Build message
MSG="⚠️ *Agent Watchdog — $DATE*"$'\n'$'\n'
MSG+="Overdue agents:"$'\n'
for item in "${OVERDUE[@]}"; do
  MSG+="• $item"$'\n'
done

if send_telegram "$MSG"; then
  echo "$(date -Iseconds) Telegram alert sent successfully."
else
  echo "$(date -Iseconds) Failed to send Telegram alert."
  exit 1
fi
