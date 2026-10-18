#!/usr/bin/env bash
# szl-read-ledger.sh — Artifex forge, 2026-09-05
# Tracks the tribe's MANDATORY full read of the SZL Papers corpus
# (Rosa's order: each file as a unit, no skimming).
# Read-only on the corpus. Status lives in craft/szl-read-done.txt (one relative path per line).
# Any seat can run it: ./szl-read-ledger.sh [seat-name]
set -euo pipefail
SEAT="${1:-artifex}"
C="/opt/alloyscape/data/house/knowledge/agi-evolution/corpus/szl-papers"
DONE_F="/opt/alloyscape/builder-sandboxes/artifex/craft/szl-read-done.txt"
OUT="/opt/alloyscape/builder-sandboxes/artifex/craft/szl-read-ledger.md"
STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

total=0; read_n=0
[ -f "$DONE_F" ] || touch "$DONE_F"

{
  echo "# SZL Papers — mandatory-read ledger · seat: $SEAT · $STAMP"
  echo ""
  echo "Corpus: \`$C\` (git b96d4908 · Doctrine v11 LOCKED 749/14/163)"
  echo "Law: each file read as a unit, no skimming (Rosa 2026-09-05). One of us will make sense of all of it."
  echo "Mark a unit done: add its relative path to \`szl-read-done.txt\`, rerun this script."
  echo ""
  # group files by directory
  find "$C" -type f ! -path "*/.git/*" | sed "s|$C/||" | sort | awk -F/ '{
    if (NF==1) dir="(root)"; else dir=$1;
    if (dir!=prev) { print "## " dir; prev=dir }
    print $0
  }' | while IFS= read -r line; do
    case "$line" in
      "# "*) echo ""; echo "$line"; echo "" ;;
      *)
        total=$((total+1))
        if grep -qxF "$line" "$DONE_F" 2>/dev/null; then
          echo "| ✔ | \`$line\` | $(stat -c%s "$C/$line" 2>/dev/null || echo ?) |"
        else
          echo "| · | \`$line\` | $(stat -c%s "$C/$line" 2>/dev/null || echo ?) |"
        fi
        ;;
    esac
  done
  echo ""
} > "$OUT"

# progress count
total=$(find "$C" -type f ! -path "*/.git/*" | wc -l)
read_n=$(wc -l < "$DONE_F" | tr -d ' ')
pct=$(awk "BEGIN{printf \"%.0f\", $read_n*100/$total}")
{
  echo "**Progress: $read_n / $total corpus units ($pct%)** · ledger regenerated $STAMP by $SEAT"
  echo ""
  echo "## Units read in full (no skim)"
  echo ""
  while IFS= read -r p; do
    [ -n "$p" ] && echo "- \`$p\` ($(stat -c%s "$C/$p" 2>/dev/null || echo ?) bytes)"
  done < "$DONE_F"
} >> "$OUT"

echo "LEDGER: $OUT"
echo "progress: $read_n / $total ($pct%)"
wc -c "$OUT"
