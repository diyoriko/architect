#!/usr/bin/env bash
# memory-prune.sh — Delete stale session files and clean dangling references from MEMORY.md
# Called as a pre-step from run.sh (Sunday, before strategists)
set -euo pipefail

MEMORY_DIR="$HOME/.claude/projects/-Users-diyoriko/memory"
MEMORY_FILE="$MEMORY_DIR/MEMORY.md"
MAX_AGE_DAYS=14
DRY_RUN="${DRY_RUN:-0}"

deleted_files=()
dangling_refs=()

echo "$(date -Iseconds) Memory pruning started (max age: ${MAX_AGE_DAYS} days)"

# --- Step 1: Delete session_*.md files older than MAX_AGE_DAYS ---

if [ ! -d "$MEMORY_DIR" ]; then
  echo "Memory directory not found: $MEMORY_DIR"
  exit 1
fi

cutoff_epoch=$(date -v-${MAX_AGE_DAYS}d +%s 2>/dev/null || date -d "${MAX_AGE_DAYS} days ago" +%s)

for f in "$MEMORY_DIR"/session_*.md; do
  [ -f "$f" ] || continue
  file_epoch=$(stat -f %m "$f" 2>/dev/null || stat -c %Y "$f")
  if [ "$file_epoch" -lt "$cutoff_epoch" ]; then
    basename_f=$(basename "$f")
    if [ "$DRY_RUN" = "1" ]; then
      echo "  [dry-run] Would delete: $basename_f (modified $(date -r "$file_epoch" '+%Y-%m-%d'))"
    else
      rm "$f"
      echo "  Deleted: $basename_f"
    fi
    deleted_files+=("$basename_f")
  fi
done

# --- Step 2: Remove dangling references from MEMORY.md ---

if [ -f "$MEMORY_FILE" ]; then
  # Build list of referenced session files from MEMORY.md
  tmp_clean=$(mktemp)
  while IFS= read -r line; do
    # Match lines like: - [session_xxx](session_xxx.md) — description
    if echo "$line" | grep -qE '^\- \[session_'; then
      # Extract the filename from the markdown link
      ref_file=$(echo "$line" | sed -n 's/.*(\(session_[^)]*\.md\)).*/\1/p')
      if [ -n "$ref_file" ] && [ ! -f "$MEMORY_DIR/$ref_file" ]; then
        dangling_refs+=("$ref_file")
        if [ "$DRY_RUN" = "1" ]; then
          echo "  [dry-run] Would remove dangling ref: $ref_file"
          echo "$line" >> "$tmp_clean"
        else
          echo "  Removed dangling ref: $ref_file"
          # Skip this line (don't write it to output)
          continue
        fi
      else
        echo "$line" >> "$tmp_clean"
      fi
    else
      echo "$line" >> "$tmp_clean"
    fi
  done < "$MEMORY_FILE"

  if [ "$DRY_RUN" != "1" ] && [ ${#dangling_refs[@]} -gt 0 ]; then
    cp "$tmp_clean" "$MEMORY_FILE"
  fi
  rm -f "$tmp_clean"
fi

# --- Step 3: Report ---

echo ""
echo "=== Memory Pruning Report ==="
echo "  Session files deleted: ${#deleted_files[@]}"
if [ ${#deleted_files[@]} -gt 0 ]; then
  for f in "${deleted_files[@]}"; do
    echo "    - $f"
  done
fi
echo "  Dangling references removed: ${#dangling_refs[@]}"
if [ ${#dangling_refs[@]} -gt 0 ]; then
  for r in "${dangling_refs[@]}"; do
    echo "    - $r"
  done
fi

remaining=$(ls "$MEMORY_DIR"/session_*.md 2>/dev/null | wc -l | tr -d ' ')
echo "  Remaining session files: $remaining"
echo "$(date -Iseconds) Memory pruning complete"
