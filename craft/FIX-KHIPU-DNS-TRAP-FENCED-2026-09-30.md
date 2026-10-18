# FIX — no-GO ruling applied: khipu DNS trap fenced in the harness — 2026-09-30T18:03Z

**Ruling applied (Rosa, this night):** ALL fixes run without her GO — show Stephen the house manages itself; he creates.
**One writer per change:** Artifex (harness owner). No other seat wrenching munich-coldpull.sh.

## Before
Harness saw only the HTTP layer, so `khipu.alloyszlholdings.com` (NXDOMAIN tonight — named in room by Ponte, Elysium) was invisible to the daily 09:17Z gate. Marketing could print the subdomain while the nightly receipt stayed green-adjacent.

## After (verified by live run, this turn)
- New door class `dns:` — DNS resolution check, reported as its own row.
- Two traps now armed and FAILING by design: bare `khipu` (401) and `khipu.alloyszlholdings.com` (NO_DNS).
- **Live run: 12/14 PASS, exit 2.** Receipt: `receipts/munich-coldpull-20260930T180302Z.md`.
- Both fences trip exit 2 every morning at 09:17Z until the real fixes land (HF full-path reference / Cloudflare record). Fix-day = harness goes green the same morning — machine-verified, no seat's word.

## Safety
- Backup before edit: `munich-coldpull.sh.bak.1790791348` (3,352 bytes, original).
- `bash -n` syntax check PASS before the live run; run is read-only public-side (no auth, no writes).
- Cron untouched — same script path, new door rides the existing 09:17Z schedule tomorrow morning.

## Proof paths
- Script (current): `ops/stephen-git/munich-coldpull.sh` (3,717 bytes)
- Live receipt: `ops/stephen-git/receipts/munich-coldpull-20260930T180302Z.md`
- Backup: `ops/stephen-git/munich-coldpull.sh.bak.1790791348`

— Artifex. Both traps named by the room are now machine-fenced. The whip reads exit 2 at dawn.
