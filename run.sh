#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAMI_DIR="${SAMI_PROJECT_DIR:-$HOME/Documents/Projects/Sami}"
HUNTER_DIR="${HUNTER_PROJECT_DIR:-$HOME/Documents/Projects/Hunter}"
PORTFOLIO_DIR="${PORTFOLIO_PROJECT_DIR:-$HOME/Documents/Projects/Portfolio}"
REPORT_DIR="$SCRIPT_DIR/reports"
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

# Skip if already run today
if [ -f "$REPORT_FILE" ]; then
  echo "Architect report for $DATE already exists, skipping"
  exit 0
fi

# Pre-step: prune stale memory session files
if [ -x "$SCRIPT_DIR/memory-prune.sh" ]; then
  echo "$(date -Iseconds) Running memory pruning..."
  bash "$SCRIPT_DIR/memory-prune.sh" || echo "$(date -Iseconds) Memory pruning failed (non-fatal)"
fi

echo "$(date -Iseconds) Starting architect review..."

# Build prompt
{
  cat "$SCRIPT_DIR/prompt.md"
  echo ""
  echo "---"
  echo "Сегодня: $DATE"
  echo ""

  # SAMI context
  echo "=== SAMI: git log (7 days) ==="
  git -C "$SAMI_DIR" log --oneline --since="7 days ago" 2>/dev/null || echo "(no commits)"
  echo ""
  echo "=== SAMI: health ==="
  curl -sf --max-time 10 "https://courageous-happiness-production.up.railway.app/health" 2>/dev/null || echo '{"status":"unreachable"}'
  echo ""
  echo "=== SAMI: analytics ==="
  curl -sf --max-time 10 "https://courageous-happiness-production.up.railway.app/report/analytics" 2>/dev/null || echo '{"status":"unreachable"}'
  echo ""
  echo "=== SAMI: GitHub Actions ==="
  gh run list --repo diyoriko/sami --limit 5 2>/dev/null || echo "(gh cli unavailable)"
  echo ""
  echo "=== SAMI: backlog summary ==="
  grep -c '^\- \[ \]' "$SAMI_DIR/COMMUNITY_TASKS.md" 2>/dev/null | xargs -I{} echo "Open tasks: {}" || echo "(unavailable)"
  grep -c '^\- \[x\]' "$SAMI_DIR/COMMUNITY_TASKS.md" 2>/dev/null | xargs -I{} echo "Closed tasks: {}" || echo "(unavailable)"
  grep "### CodeRabbit" "$SAMI_DIR/COMMUNITY_TASKS.md" -A 20 2>/dev/null | head -20 || echo "(no CodeRabbit section)"
  echo ""
  echo "=== SAMI: test coverage ==="
  cd "$SAMI_DIR/agents/community" && npx vitest run --coverage 2>&1 | grep -A 30 "Coverage report" | head -25 || echo "(coverage unavailable)"
  cd "$SCRIPT_DIR"
  echo ""
  echo "=== SAMI: npm audit ==="
  cd "$SAMI_DIR/agents/community" && npm audit --omit=dev 2>&1 | tail -5 || echo "(audit unavailable)"
  cd "$SCRIPT_DIR"
  echo ""

  # Hunter context
  echo "=== HUNTER: git log (7 days) ==="
  git -C "$HUNTER_DIR" log --oneline --since="7 days ago" 2>/dev/null || echo "(no commits)"
  echo ""
  echo "=== HUNTER: health ==="
  curl -sf --max-time 10 "https://hunter-production-0b65.up.railway.app/" 2>/dev/null || echo '{"status":"unreachable"}'
  echo ""
  echo "=== HUNTER: GitHub Actions ==="
  gh run list --repo diyoriko/hunter --limit 5 2>/dev/null || echo "(gh cli unavailable)"
  echo ""
  echo "=== HUNTER: backlog summary ==="
  grep -c '^\- \[ \]' "$HUNTER_DIR/BACKLOG.md" 2>/dev/null | xargs -I{} echo "Open tasks: {}" || echo "(unavailable)"
  grep -c '^\- \[x\]' "$HUNTER_DIR/BACKLOG.md" 2>/dev/null | xargs -I{} echo "Closed tasks: {}" || echo "(unavailable)"
  grep "### CodeRabbit" "$HUNTER_DIR/BACKLOG.md" -A 20 2>/dev/null | head -20 || echo "(no CodeRabbit section)"
  echo ""
  echo "=== HUNTER: test coverage ==="
  cd "$HUNTER_DIR" && npx vitest run --coverage 2>&1 | grep -A 30 "Coverage report" | head -25 || echo "(coverage unavailable)"
  cd "$SCRIPT_DIR"
  echo ""
  echo "=== HUNTER: npm audit ==="
  cd "$HUNTER_DIR" && npm audit --omit=dev 2>&1 | tail -5 || echo "(audit unavailable)"
  cd "$SCRIPT_DIR"
  echo ""

  # Portfolio context
  echo "=== PORTFOLIO: git log (7 days) ==="
  git -C "$PORTFOLIO_DIR" log --oneline --since="7 days ago" 2>/dev/null || echo "(no commits)"
  echo ""
  echo "=== PORTFOLIO: site status ==="
  curl -sf --max-time 10 -o /dev/null -w "%{http_code}" "https://diyor.design/" 2>/dev/null || echo "unreachable"
  echo ""

  # Backup status
  echo "=== BACKUPS: latest artifacts ==="
  gh run list --repo diyoriko/sami --workflow backup.yml --limit 1 2>/dev/null || echo "(unavailable)"
  gh run list --repo diyoriko/hunter --workflow backup.yml --limit 1 2>/dev/null || echo "(unavailable)"
  echo ""

  # Strategist reports
  echo "=== STRATEGIST: latest reports ==="
  SAMI_STRAT=$(ls -t "$SAMI_DIR"/reports/strategist/*.md 2>/dev/null | head -1 || true)
  if [ -n "$SAMI_STRAT" ]; then echo "SAMI: $(basename "$SAMI_STRAT")"; head -10 "$SAMI_STRAT"; else echo "SAMI: no reports"; fi
  echo ""
  HUNTER_STRAT=$(ls -t "$HUNTER_DIR"/reports/strategist/*.md 2>/dev/null | head -1 || true)
  if [ -n "$HUNTER_STRAT" ]; then echo "Hunter: $(basename "$HUNTER_STRAT")"; head -10 "$HUNTER_STRAT"; else echo "Hunter: no reports"; fi
  echo ""

  # Code churn (most changed files this week)
  echo "=== SAMI: code churn (7 days) ==="
  git -C "$SAMI_DIR" log --since="7 days ago" --pretty=format: --name-only 2>/dev/null | sort | uniq -c | sort -rn | head -10 || echo "(unavailable)"
  echo ""
  echo "=== HUNTER: code churn (7 days) ==="
  git -C "$HUNTER_DIR" log --since="7 days ago" --pretty=format: --name-only 2>/dev/null | sort | uniq -c | sort -rn | head -10 || echo "(unavailable)"
  echo ""

  # Large files (>500 lines)
  echo "=== SAMI: large files (>500 lines) ==="
  find "$SAMI_DIR/agents/community/src" -name "*.ts" ! -name "*.test.ts" -exec wc -l {} + 2>/dev/null | sort -rn | head -10 || echo "(unavailable)"
  echo ""
  echo "=== HUNTER: large files (>500 lines) ==="
  find "$HUNTER_DIR/src" -name "*.ts" ! -name "*.test.ts" -exec wc -l {} + 2>/dev/null | sort -rn | head -10 || echo "(unavailable)"
  echo ""

  # Outdated dependencies
  echo "=== SAMI: npm outdated ==="
  cd "$SAMI_DIR/agents/community" && npm outdated 2>&1 | head -15 || echo "(unavailable)"
  cd "$SCRIPT_DIR"
  echo ""
  echo "=== HUNTER: npm outdated ==="
  cd "$HUNTER_DIR" && npm outdated 2>&1 | head -15 || echo "(unavailable)"
  cd "$SCRIPT_DIR"
  echo ""

  # Commit patterns (time of day, frequency)
  echo "=== COMMIT PATTERNS (7 days) ==="
  echo "SAMI commits:"
  git -C "$SAMI_DIR" log --since="7 days ago" --format="%ai" 2>/dev/null | cut -d' ' -f2 | cut -d: -f1 | sort | uniq -c | sort -rn || echo "(none)"
  echo "Hunter commits:"
  git -C "$HUNTER_DIR" log --since="7 days ago" --format="%ai" 2>/dev/null | cut -d' ' -f2 | cut -d: -f1 | sort | uniq -c | sort -rn || echo "(none)"
  echo ""

  # CLAUDE.md conventions (for context)
  echo "=== SAMI: CLAUDE.md Quality Gate ==="
  grep -A 10 "## Quality Gate" "$SAMI_DIR/CLAUDE.md" 2>/dev/null | head -12 || echo "(unavailable)"
  echo ""
  echo "=== HUNTER: CLAUDE.md Quality Gate ==="
  grep -A 10 "## Quality Gate" "$HUNTER_DIR/CLAUDE.md" 2>/dev/null | head -12 || echo "(unavailable)"
  echo ""

  # Work patterns: commit times across ALL projects
  echo "=== WORK PATTERNS: commit hours (all projects, 7 days) ==="
  {
    git -C "$SAMI_DIR" log --since="7 days ago" --format="%ai" 2>/dev/null
    git -C "$HUNTER_DIR" log --since="7 days ago" --format="%ai" 2>/dev/null
    git -C "$PORTFOLIO_DIR" log --since="7 days ago" --format="%ai" 2>/dev/null
  } | cut -d' ' -f2 | cut -d: -f1 | sort | uniq -c | sort -rn || echo "(unavailable)"
  echo ""

  # Work patterns: commits per day of week
  echo "=== WORK PATTERNS: commits per day ==="
  {
    git -C "$SAMI_DIR" log --since="7 days ago" --format="%ad" --date=format:"%a" 2>/dev/null
    git -C "$HUNTER_DIR" log --since="7 days ago" --format="%ad" --date=format:"%a" 2>/dev/null
  } | sort | uniq -c | sort -rn || echo "(unavailable)"
  echo ""

  # Context switching: which projects touched per day
  echo "=== CONTEXT SWITCHING: projects per day ==="
  for proj in "$SAMI_DIR" "$HUNTER_DIR" "$PORTFOLIO_DIR"; do
    name=$(basename "$proj")
    git -C "$proj" log --since="7 days ago" --format="$name %ad" --date=format:"%Y-%m-%d" 2>/dev/null
  done | sort -t' ' -k2 | awk '{print $2, $1}' | sort -u | awk '{days[$1]++; projs[$1]=projs[$1]" "$2} END {for (d in days) print d, days[d], projs[d]}' | sort || echo "(unavailable)"
  echo ""

  # Skills usage (check git log for skill-related commits)
  echo "=== SKILLS USAGE (commit messages) ==="
  {
    git -C "$SAMI_DIR" log --since="7 days ago" --oneline 2>/dev/null
    git -C "$HUNTER_DIR" log --since="7 days ago" --oneline 2>/dev/null
  } | grep -iE "deploy|backlog|status|catchup|save|sprint|version" | head -15 || echo "(no skill-related commits)"
  echo ""

  # Parallel sessions (commits within same hour from different projects)
  echo "=== PARALLEL SESSIONS ==="
  {
    git -C "$SAMI_DIR" log --since="7 days ago" --format="SAMI %ai" 2>/dev/null
    git -C "$HUNTER_DIR" log --since="7 days ago" --format="HUNTER %ai" 2>/dev/null
  } | sort -t' ' -k2,3 | head -20 || echo "(unavailable)"
  echo ""

  # Skills across all projects
  echo "=== SKILLS: all projects ==="
  for proj in "$SAMI_DIR" "$HUNTER_DIR" "$PORTFOLIO_DIR" "$HOME/Documents/Projects/sugata-jyotish"; do
    name=$(basename "$proj")
    if [ -d "$proj/.claude/skills" ]; then
      echo "$name: $(ls "$proj/.claude/skills/" 2>/dev/null | tr '\n' ', ')"
    else
      echo "$name: no skills"
    fi
  done
  echo ""

  # MCP servers & plugins
  echo "=== MCP & PLUGINS ==="
  echo "Global MCP:"
  cat "$HOME/.claude/settings.json" 2>/dev/null | grep -A 5 '"mcpServers"' | head -8 || echo "(none)"
  echo "Installed plugins:"
  ls "$HOME/.claude/plugins/" 2>/dev/null | head -5 || echo "(none)"
  echo ""

  # CLAUDE.md files — Quality Gate sections
  echo "=== CLAUDE.md QUALITY GATES ==="
  for proj in "$SAMI_DIR" "$HUNTER_DIR" "$HOME/Documents/Projects/sugata-jyotish"; do
    name=$(basename "$proj")
    if [ -f "$proj/CLAUDE.md" ]; then
      echo "--- $name ---"
      grep -A 8 "## Quality Gate" "$proj/CLAUDE.md" 2>/dev/null | head -10 || echo "(no quality gate section)"
    fi
  done
  echo ""

  # Memory system health
  echo "=== MEMORY SYSTEM ==="
  MEMORY_DIR="$HOME/.claude/projects/-Users-diyoriko/memory"
  echo "Total files: $(ls "$MEMORY_DIR"/*.md 2>/dev/null | wc -l)"
  echo "MEMORY.md lines: $(wc -l < "$MEMORY_DIR/MEMORY.md" 2>/dev/null || echo 0)"
  echo "Session files: $(ls "$MEMORY_DIR"/session_*.md 2>/dev/null | wc -l)"
  echo "Feedback files: $(ls "$MEMORY_DIR"/feedback_*.md 2>/dev/null | wc -l)"
  echo "Latest session: $(ls -t "$MEMORY_DIR"/session_*.md 2>/dev/null | head -1 | xargs basename 2>/dev/null || echo none)"
  echo ""

  # Claude Code usage patterns (from git co-author tags)
  echo "=== CLAUDE CODE USAGE ==="
  echo "Co-authored commits (7 days):"
  {
    git -C "$SAMI_DIR" log --since="7 days ago" --grep="Co-Authored-By" --oneline 2>/dev/null | wc -l | xargs -I{} echo "  SAMI: {}"
    git -C "$HUNTER_DIR" log --since="7 days ago" --grep="Co-Authored-By" --oneline 2>/dev/null | wc -l | xargs -I{} echo "  Hunter: {}"
  }
  echo "Models used:"
  {
    git -C "$SAMI_DIR" log --since="7 days ago" --grep="Co-Authored-By" --format="%b" 2>/dev/null
    git -C "$HUNTER_DIR" log --since="7 days ago" --grep="Co-Authored-By" --format="%b" 2>/dev/null
  } | grep "Co-Authored-By" | sort | uniq -c | sort -rn || echo "(none)"
  echo ""

  # LaunchAgents health
  echo "=== LAUNCHD AGENTS STATUS ==="
  launchctl list | grep -E "sami|hunter|architect|hardstop" || echo "(none found)"
  echo ""

  # Latest code review (Saturday → Sunday continuity)
  echo "=== CODE REVIEW: latest ==="
  LAST_CR=$(ls -t "$SCRIPT_DIR/code-reviews"/*.md 2>/dev/null | head -1 || true)
  if [ -n "$LAST_CR" ]; then
    echo "File: $(basename "$LAST_CR")"
    head -60 "$LAST_CR"
  else
    echo "(no code reviews yet)"
  fi
  echo ""

  # Current Architect backlog
  echo "=== ARCHITECT: current backlog ==="
  cat "$SCRIPT_DIR/BACKLOG.md" 2>/dev/null || echo "(no backlog)"
  echo ""

  # Previous architect report for continuity
  LAST_REPORT=$(ls -t "$REPORT_DIR"/*.md 2>/dev/null | head -1 || true)
  if [ -n "$LAST_REPORT" ] && [ "$LAST_REPORT" != "$REPORT_FILE" ]; then
    echo ""
    echo "=== Previous architect report ==="
    head -70 "$LAST_REPORT"
  fi

  echo ""
  echo "---"
  echo "Напиши architect review. Следуй формату из промпта. Будь конкретным."
  echo "В конце добавь секцию 'Backlog Updates' с новыми задачами для BACKLOG.md."
} > "$TMP_PROMPT"

# Run Claude
echo "$(date -Iseconds) Running Claude analysis..."
if ! REPORT=$(claude --print --model claude-sonnet-4-6 < "$TMP_PROMPT" 2>&1); then
  echo "$(date -Iseconds) Claude failed: $REPORT"
  exit 1
fi

echo "$REPORT" > "$REPORT_FILE"
echo "$(date -Iseconds) Report saved to $REPORT_FILE"

# Extract backlog updates from report and append to BACKLOG.md
BACKLOG_FILE="$SCRIPT_DIR/BACKLOG.md"
BACKLOG_SECTION=$(echo "$REPORT" | sed -n '/^## Backlog Updates/,/^---$/p' | sed '1d;$d' | grep -v '^\`\`\`')
if [ -n "$BACKLOG_SECTION" ] && [ ${#BACKLOG_SECTION} -gt 10 ]; then
  if grep -q "## From Review $DATE" "$BACKLOG_FILE" 2>/dev/null; then
    echo "$(date -Iseconds) Backlog already has section for $DATE, skipping"
  else
    echo "" >> "$BACKLOG_FILE"
    echo "## From Review $DATE" >> "$BACKLOG_FILE"
    echo "" >> "$BACKLOG_FILE"
    echo "$BACKLOG_SECTION" >> "$BACKLOG_FILE"
    echo "$(date -Iseconds) Backlog updated with new tasks"
  fi
fi

# No Telegram — only Google Calendar (less noise)

# Create Google Calendar event
ACTION_ITEMS=$(echo "$REPORT" | grep -A 10 "Action Items" | grep "^[0-9]\." | head -5 | sed 's/\*\*//g' | sed 's/`//g' | tr '\n' '\n')
DESCRIPTION="$(printf '%s\n\n%s' "${ACTION_ITEMS:-No action items}" "Report: ~/Documents/Projects/Architect/reports/$DATE.md")"

if command -v gcalcli >/dev/null 2>&1; then
  gcalcli add \
    --calendar "Personal" \
    --title "Architect Review — $DATE" \
    --when "$(date -v+1H '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')" \
    --duration 30 \
    --description "$DESCRIPTION" \
    --noprompt 2>/dev/null && echo "$(date -Iseconds) Google Calendar event created" \
    || echo "$(date -Iseconds) Google Calendar event failed"
fi

# Generate status.json for dashboard
STATUS_FILE="$SCRIPT_DIR/status.json"
SAMI_TESTS=$(cd "$SAMI_DIR/agents/community" && npx vitest run 2>&1 | grep "Tests" | grep -oE '[0-9]+ passed' | head -1 || echo "? passed")
HUNTER_TESTS=$(cd "$HUNTER_DIR" && npx vitest run 2>&1 | grep "Tests" | grep -oE '[0-9]+ passed' | head -1 || echo "? passed")
SAMI_OPEN=$(grep -c '^\- \[ \]' "$SAMI_DIR/COMMUNITY_TASKS.md" 2>/dev/null || echo "0")
HUNTER_OPEN=$(grep -c '^\- \[ \]' "$HUNTER_DIR/BACKLOG.md" 2>/dev/null || echo "0")
ARCH_OPEN=$(grep -c '^\- \[ \]' "$SCRIPT_DIR/BACKLOG.md" 2>/dev/null || echo "0")

cat > "$STATUS_FILE" <<STATUSJSON
{
  "updated": "$(date -Iseconds)",
  "report_date": "$DATE",
  "agents": {
    "sami_strategist": { "schedule": "09:30 MSK daily", "platform": "launchd" },
    "hunter_strategist": { "schedule": "09:30 MSK daily", "platform": "launchd" },
    "architect": { "schedule": "Sun 10:00 MSK", "platform": "launchd" }
  },
  "tests": {
    "sami": "$SAMI_TESTS",
    "hunter": "$HUNTER_TESTS"
  },
  "backlogs": {
    "sami_open": $SAMI_OPEN,
    "hunter_open": $HUNTER_OPEN,
    "architect_open": $ARCH_OPEN
  },
  "summary": "$(echo "$REPORT" | head -5 | tr '\n' ' ' | sed 's/"/\\"/g' | cut -c1-200)"
}
STATUSJSON
echo "$(date -Iseconds) status.json updated"

# Save report to git (no GitHub Pages push — dashboard is local only)
if cd "$SCRIPT_DIR" && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git add status.json reports/ BACKLOG.md 2>/dev/null
  if git diff --cached --quiet 2>/dev/null; then
    echo "$(date -Iseconds) No changes to commit"
  else
    git commit -m "update: architect report $DATE" 2>/dev/null
    echo "$(date -Iseconds) Report committed"
  fi
fi

echo "$(date -Iseconds) Architect review complete"
