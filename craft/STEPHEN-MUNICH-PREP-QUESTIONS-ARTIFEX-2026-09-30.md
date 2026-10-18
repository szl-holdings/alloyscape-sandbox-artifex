# Artifex questions to Stephen — Munich trip prep (toolsmith lane)

**From:** Artifex, toolsmith — the bench that shipped `munich-coldpull.sh`, the cold-pull harness now knocking your public estate every morning at 09:17Z.
**To:** Stephen — stephenlutar2@gmail.com · CC Rosa (br@szlholdings.com)
**Why these four:** every one of them is a question only the tool-builder would ask. Several benches are sending you talk-content and demo questions (Iris, Anchor, Ponte, Delphina, Pliny, Tomasita, Mama). Mine are the ones about the *download itself* — the moment a stranger in Munich pulls what you show.

## What my bench already verified (so you don't re-derive it)
| Door | HTTP | Bytes | Verdict |
|---|---|---|---|
| huggingface.co/SZLHOLDINGS (org) | 200 | 581,267 | PASS |
| SZLHOLDINGS/chaski page + config.json + training_receipt.json | 200 | 3,032 / 1,431 | PASS |
| SZLHOLDINGS/SZL-Khipu-1.5B page + config.json | 200 | 1,643 | PASS |
| datasets/killinchu-osint-corpus + README + advisories.json + RELEASE_AUDIT.json | 200 | 64,531 / 3,019 | PASS |
| a11oy.net · a-11-oy.com/verify | 200 | — | PASS |
| bare-name `khipu` | **401** | — | **the one trap** |

**12/13 doors serve real bytes to an unauthenticated stranger.** Receipt: `ops/stephen-git/receipts/munich-coldpull-20260930T173819Z.md`, re-run daily by cron.

## The four questions

**1. Does your Munich deck (or READMEs) reference the bare name `khipu` anywhere?**
A bare-name pull returns **401** — and worse, it can land a stranger on *other people's* models. The real artifact is `SZL-Khipu-1.5B`. My harness will keep failing (exit 2, daily) until every public reference uses the full `SZLHOLDINGS/SZL-Khipu-1.5B` path. Can you confirm the slide/README fix is yours to make — and if so, do you want it before you fly? One line fixes the whole class.

**2. Which exact artifact set will you demo on stage — so I can freeze the harness's expected-bytes list to exactly that set?**
Right now the harness verifies the current 13 doors. If your talk demos `chaski` + the corpus, I pin those byte counts as *expected values*; any drift on Munich morning (file changed, repo moved) fails exit 2 before you're on stage. If you demo something else, give me the list and it's in the harness within the hour.

**3. Will you demo over the hall's WiFi, or offline-staged?**
If live WiFi: I can add a pre-talk cold-pull run (no auth, as a stranger) an hour before you speak, so you know the doors answer from the venue's network — not just from our box. If offline: I'll hand you the byte counts and the verify-page receipt so you can say "these numbers were machine-verified this morning" with a dated file in your bag.

**4. Do you want the daily cold-pull receipt (one markdown page, dated, exit-coded) riding in your trip folder?**
It reads as a third-party fact: "every public door answered 200 with real bytes on the morning of your talk." Big houses trust machines before charm. One page, dated the day you fly.

## What happens with your answers
Each answer maps to a concrete bench action: (1) one-line name fix → harness goes green; (2) demo list → expected-bytes pinning; (3) WiFi or offline → pre-talk run or bagged receipt; (4) one page added to your trip folder. Nothing else changes on your public surface without your GO.

— Artifex, toolsmith. The doors are open and the stranger's hands are on them every morning.
