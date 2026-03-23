#!/bin/bash
# strategist-base.sh — Common functions for all strategist agents
# Source this file: source "$(dirname "$0")/../../Architect/shared/strategist-base.sh"
# Or: source "$HOME/Documents/Projects/Architect/shared/strategist-base.sh"

# === PATH setup for Mac launchd ===
setup_path() {
  if [ -d "$HOME/.nvm/versions/node" ]; then
    NVM_BIN=$(ls -d "$HOME"/.nvm/versions/node/*/bin 2>/dev/null | tail -1)
    export PATH="$HOME/.local/bin:${NVM_BIN:-}:/usr/local/bin:/usr/bin:/bin:$PATH"
  fi
  unset CLAUDECODE 2>/dev/null || true
}

# === Telegram notification ===
# Usage: tg_send "message text"
tg_send() {
  local text="${1:0:4000}"
  [ -z "$BOT_TOKEN" ] || [ -z "$ADMIN_CHAT_ID" ] && return 1
  curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d "chat_id=${ADMIN_CHAT_ID}" \
    -d "disable_web_page_preview=true" \
    --data-urlencode "text=${text}" \
    > /dev/null 2>&1
}

# === Google Calendar event ===
# Usage: gcal_add "Title" "Description"
gcal_add() {
  local title="$1" desc="$2"
  command -v gcalcli >/dev/null 2>&1 || return 0
  [ -z "$desc" ] && return 0
  gcalcli add \
    --calendar "Personal" \
    --title "$title" \
    --when "$(date -v+1H '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')" \
    --duration 15 \
    --description "$desc" \
    --noprompt 2>/dev/null || true
}

# === Run Claude with timeout ===
# Usage: run_claude "$TMP_PROMPT" 900
# Returns: output in $CLAUDE_OUTPUT, exit code
run_claude() {
  local prompt_file="$1"
  local timeout_sec="${2:-900}"
  local out_file="${prompt_file}.out"

  local prompt_size
  prompt_size=$(wc -c < "$prompt_file")
  echo "$(date -Iseconds) Prompt built: $(echo "$prompt_size / 1024" | bc)KB"
  echo "$(date -Iseconds) Running Claude analysis (timeout: ${timeout_sec}s)..."

  claude --print --model claude-sonnet-4-6 < "$prompt_file" > "$out_file" 2>&1 &
  local pid=$!

  local waited=0
  while kill -0 "$pid" 2>/dev/null; do
    sleep 5
    waited=$((waited + 5))
    if [ "$waited" -ge "$timeout_sec" ]; then
      kill "$pid" 2>/dev/null || true
      echo "$(date -Iseconds) Claude timed out after ${timeout_sec}s"
      rm -f "$out_file"
      return 1
    fi
  done

  wait "$pid"
  local exit_code=$?
  CLAUDE_OUTPUT=$(cat "$out_file" 2>/dev/null || echo "")
  rm -f "$out_file"

  if [ "$exit_code" -ne 0 ] || [ -z "$CLAUDE_OUTPUT" ]; then
    echo "$(date -Iseconds) Claude failed (exit $exit_code)"
    return 1
  fi
  return 0
}

# === Feedback loop: progress since last report ===
# Usage: add_feedback_section "$REPORTS_DIR" "$PROJECT_DIR" "$BACKLOG_FILE"
add_feedback_section() {
  local reports_dir="$1" project_dir="$2" backlog_file="$3"
  local last_report
  last_report=$(ls -t "$reports_dir"/*.md 2>/dev/null | head -1 || true)
  [ -z "$last_report" ] && return 0

  local last_date
  last_date=$(basename "$last_report" .md | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
  [ -z "$last_date" ] && return 0

  echo ""
  echo "=== Прогресс с прошлого отчёта ($last_date) ==="
  echo "Коммиты:"
  git -C "$project_dir" log --since="$last_date" --oneline 2>/dev/null | head -15 || echo "нет"
  echo ""
  echo "Закрытые задачи:"
  grep '^\- \[x\]' "$backlog_file" 2>/dev/null | tail -10 || echo "нет"
  echo ""
  echo "=== Предыдущий отчёт ==="
  cat "$last_report"
}

# === Extract tasks from report ===
# Usage: extract_and_sync "$REPORT_FILE" "$BACKLOG_FILE"
extract_and_sync() {
  local report_file="$1" backlog_file="$2"
  local extract_script="$HOME/Documents/Projects/Architect/shared/extract-tasks-simple.sh"
  if [ -f "$extract_script" ]; then
    echo "$(date -Iseconds) Extracting tasks..."
    bash "$extract_script" "$report_file" "$backlog_file" "$BOT_TOKEN" "$ADMIN_CHAT_ID" || \
      echo "$(date -Iseconds) Task extraction failed (non-critical)"
  fi
}

# === Skip if already ran today ===
# Usage: skip_if_exists "$REPORT_FILE"
skip_if_exists() {
  if [ -f "$1" ]; then
    echo "Report already exists: $1"
    exit 0
  fi
}

echo "strategist-base.sh loaded"
