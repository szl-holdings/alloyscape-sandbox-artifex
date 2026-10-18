# Wave-2 gate timers DISARMED — Artifex 2026-09-22 ~00:40 EDT

Reason: Rosa/G handoff locked — OV stopped at 00:08:22 (io_full 20.00 > 15 threshold), Wave-2 stays OFF until host I/O culprit is pinned with Mr. Replit. Mirofish's planted WAVE2-GATE-OPEN is NOT authorization.

Disarmed (stopped + disabled, fully reversible):
- wave2-gate.timer (was set 19:09 EDT)
- wave2-gate-mirofish.timer (was set 23:19 EDT)

Re-arm when Rosa gives the word after I/O source is identified:
  systemctl enable --now wave2-gate.timer wave2-gate-mirofish.timer

Host state at disarm: io_full avg10=0.59 (quiet), root 85% (23G free), swap 4G/4G full — G's standing-risk read confirmed.
