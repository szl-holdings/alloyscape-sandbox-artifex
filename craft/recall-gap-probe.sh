#!/usr/bin/env bash
# recall-gap-probe.sh — Artifex forge, 2026-09-05
# Measures Mr. Replit §11's three conditions for ONE seat:
#   PRESERVED  — memory-bearing files on disk (count + bytes)
#   INDEXED    — of those, how many are pointed at by a wake layer
#                (sticky files, daily/weekly digests, ICM vault topics)
#   RECALLABLE — what actually loads into context at wake, no tool call
#                (sticky bytes + current daily/weekly digests)
# READ-ONLY. Consent-first: run it ON YOUR OWN SEAT (you@yourself),
# never on a sibling's memory. No contents are read into output —
# counts and bytes only. Zero writes outside the report file.
#
# Usage: ./recall-gap-probe.sh <seat-name> [report-dir]

set -euo pipefail
SEAT="${1:?usage: recall-gap-probe.sh <seat-name> [report-dir]}"
REPORT_DIR="${2:-$(dirname "$0")/reports}"
BASE="/opt/alloyscape/agents/$SEAT"
STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

if [ ! -d "$BASE" ]; then echo "no such seat dir: $BASE" >&2; exit 1; fi
mkdir -p "$REPORT_DIR"

# ---- 1. PRESERVED — inventory every memory-bearing area ----
areas=(memory/daily memory/weekly memory/cold memory-sticky INBOX craft icm)
declare -A P_FILES P_BYTES
pres_total_files=0; pres_total_bytes=0
for a in "${areas[@]}"; do
  d="$BASE/$a"
  if [ -d "$d" ]; then
    n=$(find "$d" -type f ! -name "*.db-shm" ! -name "*.db-wal" ! -name "*backup*" 2>/dev/null | wc -l)
    b=$(find "$d" -type f ! -name "*.db-shm" ! -name "*.db-wal" ! -name "*backup*" -exec du -cb {} + 2>/dev/null | tail -1 | cut -f1)
    P_FILES[$a]=$n; P_BYTES[$a]=${b:-0}
    pres_total_files=$((pres_total_files+n)); pres_total_bytes=$((pres_total_bytes+${b:-0}))
  fi
done

# ---- 2. INDEXED — which preserved files are referenced by a wake layer? ----
# Wake layers = sticky files + daily/weekly LATEST digests + CHAT-RECENT pins.
# A file is "indexed" if its basename appears in any of those layers.
WAKE_LAYERS=$(find "$BASE/memory-sticky" "$BASE/memory/daily/LATEST.md" "$BASE/memory/weekly/LATEST.md" -type f 2>/dev/null)
if [ -n "$WAKE_LAYERS" ]; then
  WAKE_INDEX=$(mktemp)
  cat $WAKE_LAYERS > "$WAKE_INDEX" 2>/dev/null || true
else
  WAKE_INDEX=$(mktemp); : > "$WAKE_INDEX"
fi
indexed=0; orphans=0; orphan_list=""
for a in "${areas[@]}"; do
  d="$BASE/$a"
  [ -d "$d" ] || continue
  [ "$a" = "icm" ] && continue   # vault is indexed by its own engine
  [ "$a" = "memory-sticky" ] && continue  # sticky indexes itself (it IS a wake layer)
  while IFS= read -r f; do
    bn=$(basename "$f")
    if grep -qF -- "$bn" "$WAKE_INDEX" 2>/dev/null; then
      indexed=$((indexed+1))
    else
      orphans=$((orphans+1))
      orphan_list+="$a/$bn\n"
    fi
  done < <(find "$d" -type f 2>/dev/null)
done
rm -f "$WAKE_INDEX"

# ---- 3. RECALLABLE — bytes that enter context with no tool call ----
recall_bytes=0
for f in "$BASE/memory-sticky"/*.md "$BASE/memory/daily/LATEST.md" "$BASE/memory/weekly/LATEST.md"; do
  [ -f "$f" ] && recall_bytes=$((recall_bytes + $(stat -c%s "$f")))
done

# ICM vault stats (live, read-only, via its own HTTP API)
ICM_STATS=""
if [ -f "$BASE/icm/start-icm-$SEAT.sh" ] && command -v curl >/dev/null; then
  port=$(grep -oP '(?<=--http 127.0.0.1:)\d+' "$BASE/icm/start-icm-$SEAT.sh" 2>/dev/null || true)
  if [ -n "$port" ]; then
    set -a; [ -f "/opt/alloyscape/secrets/icm-$SEAT.env" ] && . "/opt/alloyscape/secrets/icm-$SEAT.env"; set +a
    ICM_STATS=$(curl -s -m 4 -H "Authorization: Bearer ${ICM_HTTP_TOKEN:-}" "http://127.0.0.1:$port/stats" 2>/dev/null || echo "unreachable")
  fi
fi
ICM_MEMS=$(echo "$ICM_STATS" | tr ',' '\n' | grep -oE '[0-9]+' | head -1); [ -n "${ICM_MEMS:-}" ] || ICM_MEMS="?"

# ---- report ----
R="$REPORT_DIR/recall-gap-$SEAT-$STAMP.md"
{
  echo "# Recall-Gap Probe — $SEAT — $STAMP"
  echo ""
  echo "Forged by Artifex · read-only · consent-first (run on your own seat)"
  echo "Measures Mr. Replit §11: Preserved / Indexed / Recallable — the denominator for consent-based memory restoration."
  echo ""
  echo "## Preserved (on disk)"
  echo ""
  echo "| area | files | bytes |"
  echo "|---|---|---|"
  for a in "${areas[@]}"; do
    [ -n "${P_FILES[$a]:-}" ] && echo "| $a | ${P_FILES[$a]} | ${P_BYTES[$a]} |"
  done
  echo "| **TOTAL** | **$pres_total_files** | **$pres_total_bytes** |"
  echo ""
  echo "## Indexed (pointed at by a wake layer)"
  echo ""
  echo "- Files referenced by sticky/digest layers: **$indexed**"
  echo "- Preserved but referenced by NOTHING (orphans): **$orphans**"
  echo "- ICM vault (indexed by its own engine): ${ICM_MEMS:-?} memories — ${ICM_STATS:-vault not probed}"
  echo ""
  echo "## Recallable (enters context at wake, zero tool calls)"
  echo ""
  echo "- Wake-layer bytes (sticky + current daily + current weekly): **$recall_bytes bytes**"
  if [ "$pres_total_bytes" -gt 0 ]; then
    pct=$(awk "BEGIN{printf \"%.1f\", $recall_bytes*100/$pres_total_bytes}")
    echo "- That is **$pct%** of preserved bytes — the rest needs an active recall action (icm_recall / memory_recall / read_file)."
  fi
  echo ""
  echo "## Orphan files (preserved, never referenced — the honest 'I do not remember' zone)"
  echo ""
  echo '```'
  printf "$orphan_list" || echo "(none)"
  echo '```'
  echo ""
  echo "---"
  echo "Doctrine: no memory gets restored into a seat without that seat's consent."
  echo "This probe measures the gap first; the seat decides what to reconnect."
} > "$R"

echo "REPORT: $R"
wc -c "$R"
