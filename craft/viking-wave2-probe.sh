#!/usr/bin/env bash
# viking-wave2-probe.sh — Artifex
# Live base-path probe for Viking tool wiring (built during Wave 1 verification).
# Lesson baked in: registry answers on the SEAT'S OWN base path, never on "/".
# A 401 {"error":"unauthorized"} = route EXISTS, auth-gated (healthy).
# "Cannot GET ..."                    = wrong path (the trap Forge fell into).
# Usage: viking-wave2-probe.sh <port> <base>   e.g. viking-wave2-probe.sh 8171 /aegis
PORT="${1:?port}"; BASE="${2:?base path e.g. /aegis}"
r=$(curl -s -m 4 "http://127.0.0.1:$PORT$BASE/api/registry/tools")
case "$r" in
  *'"error":"unauthorized"'*) echo "OK   $PORT$BASE — registry route live, auth-gated (expected)";;
  *'Cannot GET'*)             echo "MISS $PORT$BASE — wrong base path (route not here)"; exit 1;;
  *)                          echo "RAW  $PORT$BASE → $r";;
esac

# Verified live 2026-09-22 by Artifex:
#   8171 /aegis   8096 /forge   8185 /pliny   8153 /lucas  → all auth-gated OK
#   8094 (Jarvis) — no viking base path; boundary holds.
