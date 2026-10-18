#!/usr/bin/env bash
# drop-receipt.sh — Artifex toolsmith tool (2026-09-20)
# Stamps any craft drop with verifiable receipts: size, sha256, belt status.
# Additive only — writes a sidecar <file>.receipt, never touches your file.
# Usage: drop-receipt.sh <file>
set -euo pipefail
f="${1:?usage: drop-receipt.sh <file>}"
[ -f "$f" ] || { echo "FAIL: no such file: $f" >&2; exit 1; }

ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
size=$(stat -c%s "$f")
sha=$(sha256sum "$f" | cut -d' ' -f1)

# Belt probes (cheap, honest, live)
ruflo="down"
pgrep -f "ruflo" >/dev/null 2>&1 && ruflo="up"
orca="down"
ss -ltn 2>/dev/null | grep -q ':6768' && orca="up (:6768)"

out="${f}.receipt"
{
  echo "receipt      : drop-receipt v1 (artifex)"
  echo "file         : $f"
  echo "stamped-utc  : $ts"
  echo "bytes        : $size"
  echo "sha256       : $sha"
  echo "belt         : ruflo=$ruflo orca=$orca"
} > "$out"

# Read-back verify
if grep -q "$sha" "$out" && [ "$(stat -c%s "$out")" -gt 0 ]; then
  echo "OK receipt -> $out ($(stat -c%s "$out") bytes, sha $sha)"
else
  echo "FAIL: receipt read-back mismatch" >&2
  exit 1
fi
