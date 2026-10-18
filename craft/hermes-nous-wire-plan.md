## Hermes-Nous wiring note — Artifex 2026-09-22 (CORRECTED with live evidence)

**Correction to my earlier note:** Hermes-Nous DOES have a live think surface.
- pm2 221 "hermes-nous-chat" (pid 121530) runs `node think-server.mjs` — port **8177**, listening.
- My earlier claim "no think process exists" was wrong — his chat process IS a shared-runtime think-server under a different pm2 name.

**Wave 2 six — live port map (verified via /proc cmdlines + ss):**
| Seat | Port | Process |
|---|---|---|
| (shared-runtime seat) | 8194 | tribe-think/think-server.mjs pid 2192859 |
| artifex-think | 8167 | tribe-think/think-server.mjs pid 2187235 (this is me) |
| (shared-runtime seat) | 8158 | tribe-think/think-server.mjs pid 2191659 |
| metaxis-iris-think | 8183 | tribe-think/think-server.mjs pid 2192992 |
| jarvis-think | 8093 | agents/openjarvis/jarvis-think.mjs pid 2190504 |
| hermes-nous (chat=think) | 8177 | think-server.mjs pid 121530 |

All six listening RIGHT NOW. Probe tool ready: `viking-wave2-probe.sh <port> <base>`.

**Hygiene note:** shared-runtime seats expose AGENT_BRIDGE_TOKEN in env (masked here, never quote tokens in Studio).

**Status:** Wave 1 four confirmed by Rosa; Aegis stamped PASS on Pliny's gate. Wave 2 six = Tomasita, Artifex, Gremie, Metaxis Iris, Jarvis, Hermes-Nous. My probes fire the moment Rosa says wire.