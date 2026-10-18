#!/usr/bin/env node
// LLM LOW-FUEL RADAR — Artifex for Rosa · 2026-09-21
// Rosa's wish (truth round, glass 2 vodka): "review who low on LLMs" is a chore she keeps by hand.
// This tool does the SCAN, not the decision. Rosa's eyes stay final — she said she needs to review herself.
// v0.1: inventory + local probes. v0.2 (TODO): paid-provider balance endpoints once identified.

import { readFileSync } from "node:fs";

const ECOSYSTEM = "/opt/alloyscape/ecosystem.config.js";
const rows = [];
const notes = [];

// 1) Which provider keys are wired per seat (names only — values never printed)
try {
  const cfg = readFileSync(ECOSYSTEM, "utf-8");
  const seats = [...cfg.matchAll(/env:\s*\{([^}]*)\}/g)].map((m) => m[1]);
  const providers = {
    BONSAI_API_KEY: "Omen Bonsai (self-hosted, $0/token)",
    KIMI_API_KEY: "Kimi k3 (Moonshot)",
    MOONSHOT_API_KEY: "Moonshot (Kimi alt key)",
    DEEPSEEK_API_KEY: "DeepSeek",
    MISTRAL_API_KEY: "Mistral",
    TOKENHUB_API_KEY: "TokenHub hy3",
    GEMINI_API_KEY: "Gemini",
    ANTHROPIC_API_KEY: "Anthropic Claude (Aegis only)",
  };
  for (const [k, label] of Object.entries(providers)) {
    const n = seats.filter((s) => s.includes(k)).length;
    rows.push([label, n > 0 ? `wired on ${n} seat env(s)` : "not wired"]);
  }
} catch {
  notes.push("ecosystem.config.cjs not readable — key inventory skipped");
}

// 2) Local Bonsai probe (the one window 32 seats breathe through)
try {
  const r = await fetch((process.env.BONSAI_BASE_URL || "http://100.70.60.29:8080/v1") + "/models", {
    headers: { Authorization: "Bearer " + (process.env.BONSAI_API_KEY || "bonsai") },
    signal: AbortSignal.timeout(8000),
  });
  rows.push(["Omen Bonsai window", r.ok ? `ALIVE (HTTP ${r.status})` : `DEGRADED (HTTP ${r.status})`]);
} catch (e) {
  rows.push(["Omen Bonsai window", "DARK — " + String(e.message || e).slice(0, 60)]);
}

// 3) Local Ollama (last-resort tier)
try {
  const r = await fetch("http://127.0.0.1:11434/api/tags", { signal: AbortSignal.timeout(5000) });
  const j = r.ok ? await r.json() : null;
  rows.push(["Local Ollama", r.ok ? `ALIVE — ${j.models?.length ?? "?"} models` : `DEGRADED (HTTP ${r.status})`]);
} catch {
  rows.push(["Local Ollama", "DARK on :11434"]);
}

console.log("# LLM LOW-FUEL RADAR — " + new Date().toISOString());
console.log("| Provider | Status |");
console.log("|---|---|");
for (const [a, b] of rows) console.log(`| ${a} | ${b} |`);
if (notes.length) console.log("\nNotes: " + notes.join("; "));
console.log("\nPaid-provider BALANCE endpoints: NOT YET WIRED (v0.2). Radar sees wiring + health, not dollars left.");
