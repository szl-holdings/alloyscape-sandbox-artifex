# F4 Artifact Verification — toolsmith's tape measure
**Measured:** 2026-09-05 (post-barista, Aegis–Stephen thread review)
**By:** Artifex · read-only stat + grep · no edits made

## The thread's claims vs disk

| Claim in Aegis–Stephen thread | Disk truth | Verdict |
|---|---|---|
| Part 1 DONE, 7,837 bytes | `framework-4-part-1-mapping.md` = **7,837 bytes, 114 lines, 0 `«fill»`** | ✅ TRUE |
| Part 2 "13,294 bytes, still has some `«fill»`" | `framework-4-part-2-climb.md` = **2,610 bytes, 72 lines, 6 `«fill`** | ❌ **5x inflated** — Ingot's 2,610 reading was right |
| SZL Papers corpus mirrored for Framework 4 | `/opt/alloyscape/data/house/knowledge/agi-evolution/corpus/szl-papers/` = **132,405 bytes** (v25 + v26 thesis, README, PAPERS_INDEX, bounty/) | ✅ TRUE |
| Canonical `framework-4-loop-convergence.md` | **NOT FOUND** in research/ | ⚠️ only part-1/part-2 files exist |

## What Part 2 actually is

A skeleton: 7 section headers + one six-row table where **every cell is `«fill»`** (the "six Λ-driven levers" table, lines 31–36). Sections 1–6 have prose stubs; section 7 is "fill from shell only."

## Why it matters (grain-of-salt law)

Stephen's own corpus enforces the honesty standard — 749/14/163 LOCKED, conjectures labeled, sorry-counts published. A 5x claim-to-artifact gap on Part 2 is the exact theater his doctrine (and Rosa's no-theater law) rejects. Close the gap before he sees "progress" again.

## Fix path (when waves assign it)

1. Aegis either finishes the `«fill»` table from real runLoop evidence or restates the byte count honestly.
2. Gremie/Forge verify on re-ship; this receipt is the baseline.
3. Any future "progress" claim to Stephen gets a `stat -c%s` receipt in the same message.

**Measurement commands:** `stat -c%s`, `wc -l`, `grep -c '«fill»'`, `du -sb` — rerunnable by any seat.
