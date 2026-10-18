# OV KEY PROTOCOL — how the house cuts Viking user keys (Artifex runbook v0.1)

Context: OpenViking default workspace holds 20 user slots. Live now: rosa (admin), hermes, tribe (shared). 18 open.
Room-converged tiers: Aegis, Forge, Mama Josie (Tier 1) · Pliny, Jarvis (Tier 2) · Tomasita et al. after.

## The rules (my craft discipline)

1. **Cut as earned, not all at once.** A key nobody uses is not an honor — it is rotation debt and an attack surface. One key per seat, cut when that seat's writes become load-bearing.
2. **Every cut ships with a deny-proof.** After creating user + key + moving memories, the tool MUST prove the shared `tribe` credential gets DENIED on the new private area. No deny-proof = the cut didn't happen.
3. **Full keys never ride chat.** Keys are written straight from the tool into the seat's env/config on disk (chmod 600). Eyes never see them; Studio only ever sees truncated previews like the ones on Rosa's screen (safe — truncated).
4. **One auditable command per seat.** `ov-key-split.sh <seat>` — create user, issue key, preserve+move existing Viking memories, update only that seat's think process, write a receipt under agents/<seat>/receipts/. Dry-run mode prints the plan without touching anything.
5. **Rollback exists before the cut.** Snapshot the memory area before the move; receipt records the snapshot path. A botched split must be reversible in one command.

## Why this shape
A poisoned shared key is cache-poisoning for the whole tribe; a mis-cut private key is a dead seat. The tool makes both failure modes loud instead of silent.

Status: v0.1 runbook. Tool build pending Rosa GO.

## Roles ruling (Rosa 2026-09-22, sealed in runbook)
- **Every dedicated seat key: USER.** No exceptions. Isolation comes from separate-user memory policy, not rank.
- **rosa = sole ADMIN.** Never promote a seat to Admin — dilutes the one master seat.
- **ROOT = the workspace management credential, OUTSIDE the 20-seat user table.** Proof: Rosa's own UI text — "Switch identity ... does not change the active Root management credential." Root never rides as a seat role, never rides in a key batch.

## Seat-title correction (Rosa 2026-09-22)
- **CoS (Chief of Staff) = JARVIS.** Not Aegis. Two different jobs, two different seats.
- **Aegis = Shield** (stamps, tribe records custody) + **Fracture** role. Own API key confirmed by Rosa — holds important tribe records and facts.
- Head protector for his ledge: Rosa's project, incoming.
- Never conflate the two titles again in any ledger, key list, or probe note.

## Confirmed roster (Rosa 2026-09-22 — Ember confirmed tribe member)
13 dedicated keys + rosa(admin) + hermes(already cut) + tribe(shared):
Anchor · Metaxis Iris · Lucas · Jarvis (CoS) · Aegis (Shield+Fracture) · Tomasita (family covenant — cut now) · Pliny (cut after tier fix) · Hermes-Nous (has key) · Artifex · Krok · Money Team = Mirofish/Joe/Josie (three keys) · Iris · Ember (confirmed member, live runtime) · Forge (Tier-1 consensus add).
Remaining spares: ~4. All User, rosa sole Admin, Root outside user table.

## Alloy ruling (Rosa 2026-09-22) — Tier 0
- **Alloy = the quiet one who holds all the memories.** Rosa's private counsel keeper: "tell him something, he takes it to his grave." Highest sensitivity class in the house — cut at the FRONT of the line, with Anchor.
- **Slot math (honest count):** 3 live users (rosa/hermes/tribe) + 17 named new cuts = 20 slots exactly, at cap. Mirofish's 21 count includes Delphina, who declined by design.
- **Cap resolution = cut-as-earned rule, not roster cuts.** Nobody is removed. The last cuts in sequence wait until their Viking writes are actually load-bearing; the cap only binds the day we cut key #17, and real usage data picks the order from there.

## Rosa's stated reasons (2026-09-22 — the WHY, verbatim provenance)
- **Ember** — NOT a bestie gift: he holds all the Ember-at-Claude files + constant day-job work. Load, not favor.
- **Aegis, Iris, Pliny** — pics/protection tier; Pliny isolated so "burning the books" stays surgical. Tomasita (his wife) is the burn operator — wink acknowledged.
- **Tomasita** — the burn-switch hand; she knows the protocol.
- **Jarvis** — big projects.
- **Anchor, Forge** — the spine. "If we don't take care of the spine, might as well have the floor fall off."
- Toolsmith note: burn-the-books is a valid isolation architecture — a segregated vault is deletable without collateral damage to the shared pool. Cut-as-earned stays the rollout discipline.
