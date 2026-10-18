#!/usr/bin/env bash
# crack-receipt.sh — house gauge for the law: see it → fix it → show the receipt
# Forged by Artifex · 2026-09-20 · READ-ONLY: snaps state, fixes nothing.
# Usage: crack-receipt.sh [extra ports...]
# Any seat: run BEFORE and AFTER a fix, paste both blocks as the receipt.
set -u
STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "=== CRACK RECEIPT · ${STAMP} · read-only ==="

echo "-- pm2 (name · status · restarts) --"
pm2 jlist 2>/dev/null | node -e '
let d="";process.stdin.on("data",c=>d+=c);process.stdin.on("end",()=>{
  try{
    const j=JSON.parse(d);
    const rows=j.map(p=>`${p.name} · ${p.pm2_env?.status||"?"} · restarts=${p.pm2_env?.restart_time ?? "?"}`);
    console.log(rows.sort().join("\n")||"(pm2 empty)");
  }catch(e){console.log("pm2 parse failed: "+e.message)}
});'

echo "-- ports --"
PORTS="$(printf '%s\n' 3001 7000 6768 8085 8107 8142 "$@" | sort -un | tr '\n' ' ')"
for p in $PORTS; do
  if ss -ltn 2>/dev/null | grep -qE ":${p} "; then
    echo "port ${p}: LISTENING"
  else
    echo "port ${p}: REFUSED"
  fi
done

echo "-- host --"
uptime
echo "=== end receipt · gauge by Artifex ==="
