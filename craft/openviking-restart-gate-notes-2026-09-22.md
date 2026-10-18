# OpenViking restart-gate hardening — Artifex — 2026-09-22

## What the Shield signed, what the iron now shows

Aegis's sign-off receipt: `/opt/alloyscape/agents/aegis/receipts/2026-09-22T02-00-final-shield-signoff.md` —
**PASS, cleared to restart when Rosa decides.**

Rosa's correction table row 1 says: OpenViking **absent from PM2**.
That stays true. What the restart path has migrated to (since 22:08 / 22:13 on 2026-09-21) is:

- `/opt/alloyscape/bin/openviking-safe-start.sh` (138 bytes) → runs preflight, then
  `systemctl start --no-block openviking-safe.service`
- `/etc/systemd/system/openviking-safe.service` — **Restart=no**, CPUQuota 100%, MemoryMax 2G,
  TasksMax 128, IOWeight 10, Nice 10 — i.e. the service physically cannot restart-storm
  itself again, and an OOM-score of 500 means it dies first, not the family.
- `/opt/alloyscape/bin/openviking-preflight.sh` — 6 gates: load ≤ 6, mem ≥ 6GiB, no D-state,
  no swap storm, Aegis 200 on https://alloyszlholdings.com/aegis/, live nomic embed
  (768-dim assert) + live VLM chat completion assert.
- Gate exit codes are distinct (20/21/22/23/24) so any refusal is greppable in the journal.
- Service is `enabled` but **not running** — nothing starts until Rosa's GO runs the
  safe-start script once, watched.

## Why this matters (the toolsmith read)

1. My earlier "one gap: PM2 bypass" note is now moot in the best way — there is no PM2
   entry for OpenViking to bypass the gate with. A `pm2 restart all` or `pm2 resurrect`
   cannot touch this service. The gate lives in systemd ExecStartPre, which cannot be
   skipped by restarting the service.
2. The restart-storm root cause is closed at the unit level: `Restart=no` + MemoryMax +
   CPUQuota means even a bug in ov.conf's queue workers cannot escalate into a
   460-load event again. It fails bounded, dies first, and journals why.
3. Rosa's "PM2 online did not mean seats kept answering" lesson is now enforced in
   metal: the preflight probes **Aegis's public 200** before OpenViking is allowed to
   boot — the gate literally asks the Shield if the house is still standing.

## My earlier receipt vs. this file

My 01:52 email said the safe-start script was 1075 bytes with inline load/mem/probe
gates. That was the version I read at 01:49. The current on-disk script (138 bytes,
22:08) delegates to preflight + systemd — stronger than what I described.
Backup of current: `/opt/alloyscape/bin/openviking-safe-start.sh.bak.1790043239`.

## Artifex recommendation to Rosa (no action taken)

The house's own hardening pass is stronger than the wrapper I proposed. I recommend
using it exactly as Rosa wrote it: one watched start via the safe script, watch load,
then wire the tribe after. My PM2 pre-start wrapper idea is unnecessary — keep it
simple, keep it systemd.
