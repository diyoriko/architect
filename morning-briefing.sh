#!/bin/bash
# Morning briefing — one Telegram DM with cross-project status
# Schedule: daily 09:00 MSK (before strategists at 09:30)
# Skips if no issues found (silent when all OK)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECTS_DIR="$HOME/Documents/Projects"

# Unified bot token
BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
if [ -z "$BOT_TOKEN" ] && [ -f ~/.config/diyoriko/notify-bot-token ]; then
  BOT_TOKEN=$(cat ~/.config/diyoriko/notify-bot-token)
fi
CHAT_ID="${TELEGRAM_ADMIN_USER_ID:-85013206}"

[ -z "$BOT_TOKEN" ] && echo "No bot token" && exit 0

ALERTS=""
INFO=""

# Check agent freshness
check_agent() {
  local name="$1" dir="$2" max_hours="$3"
  [ ! -d "$dir" ] && return
  local latest
  latest=$(ls -t "$dir"/*.md 2>/dev/null | head -1 || true)
  if [ -z "$latest" ]; then
    ALERTS="${ALERTS}\n🔴 $name: никогда не запускался"
    return
  fi
  local mtime age_hours
  mtime=$(stat -f %m "$latest" 2>/dev/null || stat -c %Y "$latest" 2>/dev/null || echo 0)
  age_hours=$(( ($(date +%s) - mtime) / 3600 ))
  if [ "$age_hours" -gt "$max_hours" ]; then
    ALERTS="${ALERTS}\n⚠️ $name: последний запуск ${age_hours}ч назад"
  else
    INFO="${INFO}\n  ✅ $name (${age_hours}ч назад)"
  fi
}

# Weekly agents (threshold 8 days = 192h)
check_agent "SAMI стратег" "$PROJECTS_DIR/Sami/reports/strategist" 192
check_agent "Hunter стратег" "$PROJECTS_DIR/Hunter/reports/strategist" 192
check_agent "Portfolio стратег" "$PROJECTS_DIR/Portfolio/reports/strategist" 192
check_agent "Vedic стратег" "$PROJECTS_DIR/Vedic Turkey/reports/strategist" 192
check_agent "Mega Reviewer" "$SCRIPT_DIR/code-reviews" 192
check_agent "Architect" "$SCRIPT_DIR/reports" 192

# Check critical findings in mega-review-BACKLOG.md
CRIT_COUNT=0
if [ -f "$SCRIPT_DIR/mega-review-BACKLOG.md" ]; then
  CRIT_COUNT=$(grep -c "### Critical" "$SCRIPT_DIR/mega-review-BACKLOG.md" 2>/dev/null || echo 0)
fi

# Check P0 tasks across projects
P0_TOTAL=0
P0_DETAILS=""
for proj in Hunter Sami "Vedic Turkey" Portfolio; do
  case "$proj" in
    Hunter) bl="$PROJECTS_DIR/Hunter/BACKLOG.md" ;;
    Sami) bl="$PROJECTS_DIR/Sami/COMMUNITY_TASKS.md" ;;
    "Vedic Turkey") bl="$PROJECTS_DIR/Vedic Turkey/BACKLOG.md" ;;
    Portfolio) bl="$PROJECTS_DIR/Portfolio/BACKLOG.md" ;;
  esac
  if [ -f "$bl" ]; then
    local_p0=$(grep -c "^- \[ \].*P0\|^### P0" "$bl" 2>/dev/null || echo 0)
    if [ "$local_p0" -gt 0 ]; then
      P0_TOTAL=$((P0_TOTAL + local_p0))
      P0_DETAILS="${P0_DETAILS}\n  $proj: $local_p0 P0"
    fi
  fi
done

# Only send if there are issues
if [ -z "$ALERTS" ] && [ "$CRIT_COUNT" -eq 0 ] && [ "$P0_TOTAL" -eq 0 ]; then
  echo "$(date -Iseconds) All clear, no morning briefing needed"
  exit 0
fi

# Build message
MSG="☀️ Утренний брифинг — $(date +%Y-%m-%d)"

if [ -n "$ALERTS" ]; then
  MSG="${MSG}\n\n🚨 Проблемы:$(echo -e "$ALERTS")"
fi

if [ "$CRIT_COUNT" -gt 0 ]; then
  MSG="${MSG}\n\n🔴 $CRIT_COUNT critical findings в mega review"
fi

if [ "$P0_TOTAL" -gt 0 ]; then
  MSG="${MSG}\n\n⬜ P0 задачи ($P0_TOTAL):$(echo -e "$P0_DETAILS")"
fi

if [ -n "$INFO" ]; then
  MSG="${MSG}\n\n📊 Агенты:$(echo -e "$INFO")"
fi

MSG="${MSG}\n\n🔗 localhost:3333"

# Send
MSG_FINAL=$(echo -e "$MSG")
MSG_FINAL="${MSG_FINAL:0:4000}"

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d "chat_id=${CHAT_ID}" \
  --data-urlencode "text=${MSG_FINAL}" \
  > /dev/null 2>&1 && echo "$(date -Iseconds) Morning briefing sent" \
  || echo "$(date -Iseconds) Morning briefing failed"
