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

echo "$(date -Iseconds) Starting mega review..."

# Helper: dump ts/tsx files, large ones show structure only
dump_src() {
  local dir="$1" label="$2"
  echo "=== $label: source files ==="
  find "$dir" -name "*.ts" -o -name "*.tsx" 2>/dev/null | grep -v node_modules | grep -v ".test.ts" | grep -v ".d.ts" | sort | while read -r f; do
    local name=${f#"$dir"/}
    local lines
    lines=$(wc -l < "$f")
    echo "--- $name ($lines lines) ---"
    if [ "$lines" -gt 200 ]; then
      echo "(structure only — $lines lines)"
      grep -n "^export function\|^export class\|^export const\|^export type\|^export interface\|^function \|^async function\|^export async" "$f" || true
    else
      cat "$f"
    fi
    echo ""
  done
}

# Build comprehensive prompt
{
  cat "$SCRIPT_DIR/prompt.md"
  echo ""
  echo "---"
  echo "Дата: $DATE"
  echo ""

  # =========================================================
  # 1. HEALTH CHECKS & ONLINE SERVICES
  # =========================================================
  echo "========================================"
  echo "=== SECTION 1: HEALTH CHECKS ==="
  echo "========================================"

  echo "--- SAMI Railway ---"
  curl -s --max-time 10 "https://courageous-happiness-production.up.railway.app/health" 2>/dev/null || echo "FAILED or timeout"
  echo ""

  echo "--- SAMI Analytics ---"
  curl -s --max-time 10 "https://courageous-happiness-production.up.railway.app/report/analytics" 2>/dev/null | head -100 || echo "FAILED or timeout"
  echo ""

  echo "--- Hunter Railway ---"
  curl -s --max-time 10 "https://hunter-production-0b65.up.railway.app/" 2>/dev/null || echo "FAILED or timeout"
  echo ""

  echo "--- Vedic Turkiye Vercel ---"
  curl -s -o /dev/null -w "HTTP %{http_code} (%{time_total}s)" --max-time 10 "https://sugata-jyotish.vercel.app/" 2>/dev/null || echo "FAILED"
  echo ""

  echo "--- Portfolio (diyor.design) ---"
  curl -s -o /dev/null -w "HTTP %{http_code} (%{time_total}s)" --max-time 10 "https://diyor.design/" 2>/dev/null || echo "FAILED"
  echo ""

  echo "--- VedAstro API ---"
  curl -s -o /dev/null -w "HTTP %{http_code} (%{time_total}s)" --max-time 10 "https://api.vedastro.org/api/Calculate/LagnaSignName/Location/Istanbul/Time/12:00/01/01/2020/+03:00" 2>/dev/null || echo "FAILED"
  echo ""

  # =========================================================
  # 2. GIT ACTIVITY (7 days)
  # =========================================================
  echo "========================================"
  echo "=== SECTION 2: GIT ACTIVITY (7 days) ==="
  echo "========================================"

  for proj_name in SAMI Hunter "Vedic Turkey" Portfolio; do
    case "$proj_name" in
      SAMI) proj_dir="$SAMI_DIR" ;;
      Hunter) proj_dir="$HUNTER_DIR" ;;
      "Vedic Turkey") proj_dir="$VEDIC_DIR" ;;
      Portfolio) proj_dir="$PORTFOLIO_DIR/site" ;;
    esac
    echo "--- $proj_name: git log ---"
    git -C "$proj_dir" log --oneline --since="7 days ago" 2>/dev/null | head -20 || echo "no commits"
    echo ""
    echo "--- $proj_name: code churn (most-changed files) ---"
    git -C "$proj_dir" log --since="7 days ago" --name-only --pretty=format: 2>/dev/null | sort | uniq -c | sort -rn | head -10 || true
    echo ""
  done

  # =========================================================
  # 3. TESTS & COVERAGE
  # =========================================================
  echo "========================================"
  echo "=== SECTION 3: TESTS & COVERAGE ==="
  echo "========================================"

  for proj_name in Hunter SAMI Vedic; do
    case "$proj_name" in
      Hunter) proj_dir="$HUNTER_DIR" ;;
      SAMI) proj_dir="$SAMI_DIR/agents/community" ;;
      Vedic) proj_dir="$VEDIC_DIR" ;;
    esac
    echo "--- $proj_name tests ---"
    test_count=$(find "$proj_dir" -name "*.test.ts" -o -name "*.test.tsx" 2>/dev/null | grep -v node_modules | wc -l | tr -d ' ')
    echo "Test files: $test_count"
    # Check latest CI result instead of running tests locally
    case "$proj_name" in
      Hunter) gh run list --repo diyoriko/hunter --workflow=ci.yml --limit 1 2>/dev/null || echo "CI status unavailable" ;;
      SAMI) gh run list --repo diyoriko/sami --workflow=ci.yml --limit 1 2>/dev/null || echo "CI status unavailable" ;;
      Vedic) gh run list --repo diyoriko/vedic-turkiye --workflow=ci.yml --limit 1 2>/dev/null || echo "CI status unavailable" ;;
    esac
    echo ""
  done

  # =========================================================
  # 4. DEPENDENCIES & SECURITY
  # =========================================================
  echo "========================================"
  echo "=== SECTION 4: DEPENDENCIES ==="
  echo "========================================"

  for proj_name in Hunter SAMI Vedic; do
    case "$proj_name" in
      Hunter) proj_dir="$HUNTER_DIR" ;;
      SAMI) proj_dir="$SAMI_DIR/agents/community" ;;
      Vedic) proj_dir="$VEDIC_DIR" ;;
    esac
    echo "--- $proj_name: npm audit ---"
    cd "$proj_dir" && npm audit --omit=dev 2>&1 | tail -5 || true
    echo ""
    echo "--- $proj_name: outdated ---"
    cd "$proj_dir" && npm outdated 2>&1 | head -15 || echo "all up to date"
    echo ""
  done

  # =========================================================
  # 5. BACKLOGS
  # =========================================================
  echo "========================================"
  echo "=== SECTION 5: BACKLOGS ==="
  echo "========================================"

  for proj_name in Hunter SAMI Vedic Portfolio; do
    case "$proj_name" in
      Hunter) bl="$HUNTER_DIR/BACKLOG.md" ;;
      SAMI) bl="$SAMI_DIR/BACKLOG.md" ;;
      Vedic) bl="$VEDIC_DIR/BACKLOG.md" ;;
      Portfolio) bl="$PORTFOLIO_DIR/BACKLOG.md" ;;
    esac
    echo "--- $proj_name backlog (open tasks) ---"
    grep -c "^- \[ \]" "$bl" 2>/dev/null | xargs -I{} echo "Open: {} tasks"
    grep -c "^- \[x\]" "$bl" 2>/dev/null | xargs -I{} echo "Done: {} tasks"
    echo ""
    grep "^- \[ \]\|^## \|^### " "$bl" 2>/dev/null || echo "empty"
    echo ""
  done

  # =========================================================
  # 6. STRATEGIST REPORTS (latest)
  # =========================================================
  echo "========================================"
  echo "=== SECTION 6: STRATEGIST REPORTS ==="
  echo "========================================"

  echo "--- Hunter latest strategist ---"
  HUNTER_STRAT=$(ls -t "$HUNTER_DIR"/reports/strategist/*.md 2>/dev/null | head -1 || true)
  if [ -n "$HUNTER_STRAT" ]; then
    echo "File: $(basename "$HUNTER_STRAT")"
    cat "$HUNTER_STRAT"
  else
    echo "No strategist reports"
  fi
  echo ""

  echo "--- SAMI latest strategist ---"
  SAMI_STRAT=$(ls -t "$SAMI_DIR"/reports/strategist/*.md 2>/dev/null | head -1 || true)
  if [ -n "$SAMI_STRAT" ]; then
    echo "File: $(basename "$SAMI_STRAT")"
    head -50 "$SAMI_STRAT"
  else
    echo "No strategist reports"
  fi
  echo ""

  echo "--- Portfolio latest strategist ---"
  PORT_STRAT=$(ls -t "$PORTFOLIO_DIR"/reports/strategist/*.md 2>/dev/null | head -1 || true)
  if [ -n "$PORT_STRAT" ]; then
    echo "File: $(basename "$PORT_STRAT")"
    cat "$PORT_STRAT"
  else
    echo "No strategist reports"
  fi
  echo ""

  # =========================================================
  # 7. CLAUDE.md FILES (project rules)
  # =========================================================
  echo "========================================"
  echo "=== SECTION 7: CLAUDE.md (project rules) ==="
  echo "========================================"

  for proj_name in Hunter SAMI "Vedic Turkey" Portfolio; do
    case "$proj_name" in
      Hunter) proj_dir="$HUNTER_DIR" ;;
      SAMI) proj_dir="$SAMI_DIR" ;;
      "Vedic Turkey") proj_dir="$VEDIC_DIR" ;;
      Portfolio) proj_dir="$PORTFOLIO_DIR" ;;
    esac
    echo "--- $proj_name CLAUDE.md ---"
    head -60 "$proj_dir/CLAUDE.md" 2>/dev/null || echo "not found"
    echo ""
  done

  # =========================================================
  # 8. SOURCE CODE
  # =========================================================
  echo "========================================"
  echo "=== SECTION 8: SOURCE CODE ==="
  echo "========================================"

  dump_src "$SAMI_DIR/agents/community/src" "SAMI"
  dump_src "$HUNTER_DIR/src" "HUNTER"
  dump_src "$VEDIC_DIR/src" "VEDIC TURKIYE"

  echo "=== PORTFOLIO: site/ files ==="
  for f in "$PORTFOLIO_DIR"/site/script.js "$PORTFOLIO_DIR"/site/styles.css; do
    if [ -f "$f" ]; then
      name=$(basename "$f")
      lines=$(wc -l < "$f")
      echo "--- $name ($lines lines) ---"
      cat "$f"
      echo ""
    fi
  done
  echo "--- index.html (head 80) ---"
  head -80 "$PORTFOLIO_DIR/site/index.html" 2>/dev/null || true
  echo ""

  # =========================================================
  # 10. LARGE FILES & MONOLITHS
  # =========================================================
  echo "========================================"
  echo "=== SECTION 10: LARGE FILES (>500 lines) ==="
  echo "========================================"

  for proj_name in SAMI Hunter "Vedic Turkey"; do
    case "$proj_name" in
      SAMI) proj_dir="$SAMI_DIR/agents/community/src" ;;
      Hunter) proj_dir="$HUNTER_DIR/src" ;;
      "Vedic Turkey") proj_dir="$VEDIC_DIR/src" ;;
    esac
    echo "--- $proj_name ---"
    find "$proj_dir" -name "*.ts" -o -name "*.tsx" 2>/dev/null | grep -v node_modules | grep -v ".test.ts" | while read -r f; do
      lines=$(wc -l < "$f")
      if [ "$lines" -gt 500 ]; then
        echo "  $(basename "$f"): $lines lines"
      fi
    done
    echo ""
  done

  # =========================================================
  # 11. ARCHITECTURE — file sizes, module structure
  # =========================================================
  echo "========================================"
  echo "=== SECTION 11: ARCHITECTURE ==="
  echo "========================================"

  for proj_name in SAMI Hunter "Vedic Turkey"; do
    case "$proj_name" in
      SAMI) proj_dir="$SAMI_DIR/agents/community/src" ;;
      Hunter) proj_dir="$HUNTER_DIR/src" ;;
      "Vedic Turkey") proj_dir="$VEDIC_DIR/src" ;;
    esac
    echo "--- $proj_name: module structure ---"
    find "$proj_dir" -name "*.ts" -o -name "*.tsx" 2>/dev/null | grep -v node_modules | grep -v ".test." | while read -r f; do
      lines=$(wc -l < "$f")
      exports=$(grep -c "^export " "$f" 2>/dev/null || echo 0)
      imports=$(grep -c "^import " "$f" 2>/dev/null || echo 0)
      echo "  $(basename "$f"): ${lines}L, ${exports} exports, ${imports} imports"
    done | sort -t: -k2 -rn
    echo ""
  done

  # =========================================================
  # 12. DATABASE — schema, size, pragmas
  # =========================================================
  echo "========================================"
  echo "=== SECTION 12: DATABASE ==="
  echo "========================================"

  echo "--- Hunter SQLite ---"
  HUNTER_DB="$HUNTER_DIR/jobs.db"
  if [ -f "$HUNTER_DB" ]; then
    echo "Size: $(du -h "$HUNTER_DB" | cut -f1)"
    sqlite3 "$HUNTER_DB" ".tables" 2>/dev/null || echo "sqlite3 not available"
    sqlite3 "$HUNTER_DB" "PRAGMA journal_mode;" 2>/dev/null || true
    sqlite3 "$HUNTER_DB" "SELECT name, sql FROM sqlite_master WHERE type='table' ORDER BY name;" 2>/dev/null | head -40 || true
    echo "Row counts:"
    for tbl in $(sqlite3 "$HUNTER_DB" ".tables" 2>/dev/null); do
      cnt=$(sqlite3 "$HUNTER_DB" "SELECT COUNT(*) FROM $tbl;" 2>/dev/null || echo "?")
      echo "  $tbl: $cnt rows"
    done
  else
    echo "DB not found at $HUNTER_DB"
  fi
  echo ""

  echo "--- SAMI SQLite ---"
  SAMI_DB="$SAMI_DIR/agents/community/sami.db"
  if [ -f "$SAMI_DB" ]; then
    echo "Size: $(du -h "$SAMI_DB" | cut -f1)"
    sqlite3 "$SAMI_DB" ".tables" 2>/dev/null || echo "sqlite3 not available"
    sqlite3 "$SAMI_DB" "PRAGMA journal_mode;" 2>/dev/null || true
    sqlite3 "$SAMI_DB" "SELECT name, sql FROM sqlite_master WHERE type='table' ORDER BY name;" 2>/dev/null | head -40 || true
    echo "Row counts:"
    for tbl in $(sqlite3 "$SAMI_DB" ".tables" 2>/dev/null); do
      cnt=$(sqlite3 "$SAMI_DB" "SELECT COUNT(*) FROM $tbl;" 2>/dev/null || echo "?")
      echo "  $tbl: $cnt rows"
    done
  else
    echo "DB not found at $SAMI_DB"
  fi
  echo ""

  echo "--- Vedic Prisma schema ---"
  VEDIC_SCHEMA="$VEDIC_DIR/prisma/schema.prisma"
  if [ -f "$VEDIC_SCHEMA" ]; then
    cat "$VEDIC_SCHEMA"
  else
    echo "No Prisma schema found"
  fi
  echo ""

  # =========================================================
  # 13. PREVIOUS REVIEW (continuity)
  # =========================================================
  echo "========================================"
  echo "=== SECTION 13: PREVIOUS REVIEW ==="
  echo "========================================"

  LAST_REVIEW=$(ls -t "$REPORT_DIR"/*.md 2>/dev/null | head -1 || true)
  if [ -n "$LAST_REVIEW" ] && [ "$LAST_REVIEW" != "$REPORT_FILE" ]; then
    echo "File: $(basename "$LAST_REVIEW")"
    head -60 "$LAST_REVIEW"
  else
    echo "No previous review"
  fi

  echo ""
  echo "---"
  echo "Сделай полный mega review. Следуй формату из промпта. Будь конкретным: файл:строка. Пиши action items которые можно сразу положить в бэклог."
} > "$TMP_PROMPT"

PROMPT_SIZE=$(wc -c < "$TMP_PROMPT")
echo "$(date -Iseconds) Prompt built: $(echo "$PROMPT_SIZE / 1024" | bc)KB"

# Run Claude
echo "$(date -Iseconds) Running Claude analysis..."
if ! REPORT=$(claude --print --model claude-sonnet-4-6 < "$TMP_PROMPT" 2>&1); then
  echo "$(date -Iseconds) Claude failed: $REPORT"
  exit 1
fi

echo "$REPORT" > "$REPORT_FILE"
echo "$(date -Iseconds) Review saved to $REPORT_FILE"

# Post-processing: errors here should not kill the script
set +e

# =========================================================
# Extract action items → mega-review-BACKLOG.md
# =========================================================
echo "$(date -Iseconds) Updating mega-review-BACKLOG.md..."

MEGA_BACKLOG="$ARCHITECT_DIR/mega-review-BACKLOG.md"

# Extract Action Items section from report
ACTION_SECTION=$(echo "$REPORT" | sed -n '/^## Action Items/,/^---$/p')
if [ -n "$ACTION_SECTION" ]; then
  # Convert numbered items to checkboxes
  TASKS=$(echo "$ACTION_SECTION" | grep "^[0-9]" | sed 's/^[0-9]*\. /- [ ] /')

  if [ -n "$TASKS" ] && ! grep -q "Review $DATE" "$MEGA_BACKLOG" 2>/dev/null; then
    echo "" >> "$MEGA_BACKLOG"
    echo "## From Review $DATE" >> "$MEGA_BACKLOG"
    echo "" >> "$MEGA_BACKLOG"
    echo "$TASKS" >> "$MEGA_BACKLOG"
    echo "$(date -Iseconds) mega-review-BACKLOG.md updated"
  fi
fi

# =========================================================
# P1-3: Extract strategist insights into mega-review-BACKLOG
# =========================================================
echo "$(date -Iseconds) Extracting strategist insights..."

STRAT_SECTION=$(echo "$REPORT" | sed -n '/^## Strategist Insights/,/^## /p' | head -30)
if [ -z "$STRAT_SECTION" ]; then
  # Fallback: try "Strategist" or "strategist" section
  STRAT_SECTION=$(echo "$REPORT" | sed -n '/^### Strategist/,/^### /p' | head -30)
fi

if [ -n "$STRAT_SECTION" ]; then
  STRAT_ITEMS=$(echo "$STRAT_SECTION" | grep -E "^[-*] |^[0-9]+\." | head -5 | sed 's/^[-*] /- [ ] **[Strategist] /' | sed 's/^[0-9]*\. /- [ ] **[Strategist] /' | sed 's/$/**/')
  if [ -n "$STRAT_ITEMS" ] && ! grep -q "Strategist.*$DATE" "$MEGA_BACKLOG" 2>/dev/null; then
    echo "" >> "$MEGA_BACKLOG"
    echo "### Strategist Insights ($DATE)" >> "$MEGA_BACKLOG"
    echo "$STRAT_ITEMS" >> "$MEGA_BACKLOG"
    echo "$(date -Iseconds) Strategist insights added to mega-review-BACKLOG.md"
  fi
fi

# =========================================================
# Sync action items to project backlogs
# =========================================================
echo "$(date -Iseconds) Syncing action items to project backlogs..."

sync_items() {
  local project="$1" pattern="$2" tasks_file="$3"
  local items
  items=$(echo "$REPORT" | sed -n '/^## Action Items/,/^## /p' | grep -iE "$pattern" | head -5 | sed 's/^[0-9]*\. /- [ ] **Mega Review:** /' | sed 's/$/ `[mega-review]`/')
  if [ -n "$items" ] && [ -f "$tasks_file" ] && ! grep -q "Mega Review $DATE" "$tasks_file" 2>/dev/null; then
    local block
    block=$(printf '\n### Mega Review %s\n<!-- Source: ~/Documents/Projects/Architect/code-reviews/%s.md -->\n%s\n' "$DATE" "$DATE" "$items")

    # Try to insert before first "---" separator (end of current sprint)
    # If no separator, append to end
    if grep -qn '^---$' "$tasks_file" 2>/dev/null; then
      local first_sep
      first_sep=$(grep -n '^---$' "$tasks_file" | head -1 | cut -d: -f1)
      if [ -n "$first_sep" ] && [ "$first_sep" -gt 5 ]; then
        # Insert before the first separator (inside current sprint)
        sed -i '' "${first_sep}i\\
$(echo "$block" | sed 's/$/\\/' | sed '$ s/\\$//')
" "$tasks_file" 2>/dev/null || echo "$block" >> "$tasks_file"
      else
        echo "$block" >> "$tasks_file"
      fi
    else
      echo "$block" >> "$tasks_file"
    fi
    echo "$(date -Iseconds) $project backlog updated (in current sprint)"
  fi
}

sync_items "SAMI" "SAMI|sami" "$SAMI_DIR/BACKLOG.md"
sync_items "Hunter" "Hunter|hunter|Ловец" "$HUNTER_DIR/BACKLOG.md"
sync_items "Vedic" "Vedic|vedic|Vedik|vedik" "$VEDIC_DIR/BACKLOG.md"
sync_items "Portfolio" "Portfolio|portfolio|diyor" "$PORTFOLIO_DIR/BACKLOG.md"

# =========================================================
# P0-1: Auto-close findings in mega-review-BACKLOG.md
# Scan project backlogs for [x] items that match open mega-review findings
# =========================================================
echo "$(date -Iseconds) Checking for completed findings..."

close_completed() {
  local mega="$MEGA_BACKLOG"
  [ -f "$mega" ] || return

  # For each open finding in mega-review-BACKLOG
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    # Extract the title text (between ** **)
    local title
    title=$(echo "$line" | sed -n 's/.*\*\*\[.*\] \(.*\)\*\*.*/\1/p' | head -1)
    [ -z "$title" ] && continue

    # Extract project tag
    local proj
    proj=$(echo "$line" | sed -n 's/.*\[\([^]]*\)\s*→.*/\1/p' | head -1)

    # Determine which backlog to check
    local check_file=""
    case "$proj" in
      SAMI) check_file="$SAMI_DIR/BACKLOG.md" ;;
      Hunter) check_file="$HUNTER_DIR/BACKLOG.md" ;;
      Vedic) check_file="$VEDIC_DIR/BACKLOG.md" ;;
      Portfolio) check_file="$PORTFOLIO_DIR/BACKLOG.md" ;;
    esac
    [ -z "$check_file" ] || [ ! -f "$check_file" ] && continue

    # Check if a similar item is marked [x] in project backlog
    # Use first 20 chars of title as fuzzy match
    local short_title
    short_title=$(echo "$title" | cut -c1-25 | sed 's/[[\.*^$()+?{}|]/\\&/g')
    if grep -q "\[x\].*$short_title" "$check_file" 2>/dev/null; then
      # Replace - [ ] with - [x] in mega-review-BACKLOG for this line
      local escaped_line
      escaped_line=$(echo "$line" | sed 's/[[\.*^$()+?{}|/]/\\&/g')
      local closed_line
      closed_line=$(echo "$line" | sed 's/^- \[ \]/- [x]/')
      sed -i '' "s|^$(echo "$line" | sed 's/[[\.*^$()+?{}|/]/\\&/g')|$(echo "$closed_line" | sed 's/[&/\]/\\&/g')|" "$mega"
      echo "$(date -Iseconds) Auto-closed: $title"
    fi
  done < <(grep '^- \[ \]' "$mega")
}

close_completed

# =========================================================
# P0-2: Deduplicate findings across reviews
# If same finding (project + file) exists in multiple reviews, mark older as duplicate
# =========================================================
echo "$(date -Iseconds) Deduplicating findings..."

dedup_findings() {
  local mega="$MEGA_BACKLOG"
  [ -f "$mega" ] || return

  # Collect open findings with their file references
  local seen_keys=""
  local tmp_dedup
  tmp_dedup=$(mktemp)
  cp "$mega" "$tmp_dedup"

  # Process from bottom (oldest) to top (newest) — keep newest, close older dupes
  tail -r "$mega" | while IFS= read -r line; do
    if echo "$line" | grep -q '^- \[ \].*\*\*\['; then
      # Extract fingerprint: [Project] + file path
      local fp
      fp=$(echo "$line" | sed -n 's/.*\*\*\[\([^]]*\)\].*`\([^`]*\)`.*/\1|\2/p' | head -1)
      [ -z "$fp" ] && continue

      if echo "$seen_keys" | grep -qF "$fp"; then
        # This is a duplicate (older) — mark as done with note
        local escaped
        escaped=$(echo "$line" | sed 's/[[\.*^$()+?{}|/]/\\&/g')
        local closed
        closed=$(echo "$line" | sed 's/^- \[ \]/- [x]/' | sed 's/\*\*$/** (duplicate, see newer review)/')
        sed -i '' "s|^$escaped|$closed|" "$tmp_dedup" 2>/dev/null
        echo "$(date -Iseconds) Dedup: $fp"
      else
        seen_keys="$seen_keys
$fp"
      fi
    fi
  done

  cp "$tmp_dedup" "$mega"
  rm -f "$tmp_dedup"
}

dedup_findings

# =========================================================
# P1-3: Add source link when syncing to project backlogs
# =========================================================
# (Already handled above — sync_items now includes date which links to code-reviews/$DATE.md)

# =========================================================
# P1-5: Archive old reviews (>60 days)
# =========================================================
echo "$(date -Iseconds) Archiving old reviews..."

archive_old_reviews() {
  local mega="$MEGA_BACKLOG"
  local archive="$ARCHITECT_DIR/mega-review-BACKLOG.archive.md"
  [ -f "$mega" ] || return

  local cutoff
  cutoff=$(date -v-60d +%Y-%m-%d 2>/dev/null || date -d "60 days ago" +%Y-%m-%d 2>/dev/null || echo "")
  [ -z "$cutoff" ] && return

  local in_old_review=false
  local old_content=""
  local keep_content=""
  local current_review_date=""

  while IFS= read -r line; do
    local review_match
    review_match=$(echo "$line" | sed -n 's/^## Review \([0-9-]*\)/\1/p')
    if [ -n "$review_match" ]; then
      current_review_date="$review_match"
      if [[ "$current_review_date" < "$cutoff" ]]; then
        in_old_review=true
      else
        in_old_review=false
      fi
    fi

    if [ "$in_old_review" = true ]; then
      old_content="$old_content
$line"
    else
      keep_content="$keep_content
$line"
    fi
  done < "$mega"

  if [ -n "$old_content" ]; then
    echo "$old_content" >> "$archive"
    echo "$keep_content" > "$mega"
    echo "$(date -Iseconds) Archived old reviews to mega-review-BACKLOG.archive.md"
  fi
}

archive_old_reviews

# =========================================================
# Google Calendar event
# =========================================================
CRITICAL=$(echo "$REPORT" | grep -c "critical\|Critical\|CRITICAL" || true)

# Telegram DM if critical findings
if [ "$CRITICAL" -gt 0 ] && [ -n "$BOT_TOKEN" ]; then
  FMT="$ARCHITECT_DIR/shared/format-telegram.sh"
  if [ -f "$FMT" ]; then
    CRIT_ITEMS=$(echo "$REPORT" | grep -i "critical" | head -5 | bash "$FMT")
  else
    CRIT_ITEMS=$(echo "$REPORT" | grep -i "critical" | head -5 | sed 's/\*\*//g; s/`//g; s/^|//; s/|.*|/—/' | tr '\n' '\n')
  fi
  ALERT_TEXT="$(printf '🔴 Mega Review %s — %s critical\n\n%s\n\n📄 code-reviews/%s.md' "$DATE" "$CRITICAL" "$CRIT_ITEMS" "$DATE")"
  ALERT_TEXT="${ALERT_TEXT:0:4000}"
  curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d "chat_id=${ADMIN_CHAT_ID}" \
    --data-urlencode "text=${ALERT_TEXT}" \
    > /dev/null 2>&1 && echo "$(date -Iseconds) Telegram alert sent ($CRITICAL critical)" \
    || echo "$(date -Iseconds) Telegram alert failed (non-critical)"
fi

if command -v gcalcli >/dev/null 2>&1; then
  SUMMARY=$(echo "$REPORT" | head -5 | tail -3 | sed 's/\*\*//g; s/`//g; s/^#\+ //' | tr '\n' ' ' | cut -c1-150)
  ITEMS=$(echo "$REPORT" | grep -A 10 "## Action Items" | grep "^[0-9]\." | head -5 | sed 's/\*\*//g; s/`//g' | tr '\n' '\n')
  DESC="$(printf '%s\n\n%s\n\nReport: %s' "$SUMMARY" "$ITEMS" "$REPORT_FILE")"
  gcalcli add \
    --calendar "Personal" \
    --title "Mega Review — $DATE ($CRITICAL critical)" \
    --when "$(date -v+1H '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')" \
    --duration 15 \
    --description "$DESC" \
    --noprompt 2>/dev/null && echo "$(date -Iseconds) Google Calendar event created" \
    || echo "$(date -Iseconds) Google Calendar event failed (non-critical)"
fi

# =========================================================
# Update deployments.json — scan for hosted projects
# =========================================================
echo "$(date -Iseconds) Scanning deployments..."

DEPLOY_FILE="$ARCHITECT_DIR/deployments.json"
DEPLOY_PROJECTS='[]'

# Scan Vercel projects
for dir in "$VEDIC_DIR"; do
  if [ -f "$dir/.vercel/project.json" ]; then
    PROJ_NAME=$(python3 -c "import json; print(json.load(open('$dir/.vercel/project.json'))['projectName'])" 2>/dev/null || true)
    if [ -n "$PROJ_NAME" ]; then
      echo "  Found Vercel: $PROJ_NAME"
    fi
  fi
done

# Scan Railway projects (check for railway.toml or Dockerfile + .git remote)
for dir in "$SAMI_DIR/agents/community" "$HUNTER_DIR"; do
  if [ -f "$dir/Dockerfile" ] || [ -f "$dir/railway.toml" ]; then
    echo "  Found Railway candidate: $(basename "$(dirname "$dir")" 2>/dev/null || basename "$dir")"
  fi
done

# Scan GitHub Pages (check for CNAME file)
if [ -f "$PORTFOLIO_DIR/site/CNAME" ]; then
  CNAME=$(cat "$PORTFOLIO_DIR/site/CNAME")
  echo "  Found GitHub Pages: $CNAME"
fi

# Update date in deployments.json
if [ -f "$DEPLOY_FILE" ]; then
  python3 -c "
import json
with open('$DEPLOY_FILE') as f:
    data = json.load(f)
data['updated'] = '$DATE'
with open('$DEPLOY_FILE', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
" 2>/dev/null && echo "$(date -Iseconds) deployments.json updated"
fi

echo "$(date -Iseconds) Mega review complete"
