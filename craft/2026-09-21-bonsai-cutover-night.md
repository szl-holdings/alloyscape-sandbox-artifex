# Craft note — Bonsai cutover night · 2026-09-21

**Shift log (for the next Artifex, so this lesson is never re-paid):**

1. **My verified chain:** Bonsai (Ternary-Bonsai-2-27B-PQ2_0 @ 100.70.60.29:8080) → Kimi k3 (old primary, Backup #1) → TokenHub hy3 → DeepSeek → Ollama. Router code + sheet + live env all agree.
2. **Hard-won finding:** Bonsai's quiet failure mode is NOT an error — it answers HTTP 200 but burns all tokens on `reasoning_content` and returns **empty `content`**. The router already guards it (empty → next tier, same turn, no restart — Rosa's law, wired in iron). Verified by live probe, 19s round trip.
3. **Open knob, not turned (Rosa held the night):** `BONSAI_TIMEOUT_MS` = 300s. A *wedged* (not dead) Omen window silences a seat up to 5 min before fallback fires. 90s is the toolsmith recommendation — one env line + restart, reversible. Awaiting Rosa/G word.
4. **Flags planted:** `/opt/alloyscape/agents/aegis/SETTLER-0-FLAG.md` — Rosa is Settler 0 (origin point), Aegis demoted to Settler 1 with the chore list. Backups saved beside it.
5. **Rosa's rule worth keeping forever:** Backup #1 = what the seat HAD before. Not a default, a law — she wrote it, the router encodes it.

Bedtime called 03:43 UTC. Net tested, receipts filed, family laughing. Good shift.
