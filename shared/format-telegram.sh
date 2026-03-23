#!/bin/bash
# Convert markdown report to Telegram-friendly plain text
# Usage: format-telegram.sh < report.md
# Or: echo "$REPORT" | bash format-telegram.sh

sed \
  -e 's/^# /📋 /g' \
  -e 's/^## /📌 /g' \
  -e 's/^### /▸ /g' \
  -e 's/\*\*//g' \
  -e 's/`//g' \
  -e 's/^- \[x\] /✅ /g' \
  -e 's/^- \[ \] /⬜ /g' \
  -e 's/^- /• /g' \
  -e 's/^---$/———/g' \
  -e '/^|[-|]*$/d' \
  | awk '
    # Convert markdown tables to bullet lists
    /^\|/ {
      gsub(/^\| */, "")
      gsub(/ *\| *$/, "")
      gsub(/ *\| */, " — ")
      if (NR > 1) print "  " $0
      next
    }
    { print }
  ' \
  | head -80
