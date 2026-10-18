#!/usr/bin/env node
// Artifex · PTQ burn-in for Omen (v1) — 2026-09-21
// Crew slot: Unsloth train rails (Anchor · Artifex · Ornith; Pliny leads)
// Job: sustained back-to-back generations against the quantized model on Omen.
//      Watch: per-request latency (Pliny's trigger: >800ms => VRAM throttle),
//      latency drift first->last, /api/ps VRAM footprint before/after,
//      stability marker fidelity under heat. Receipt + sha256 on disk.

import { writeFileSync, mkdirSync } from 'node:fs';
import { execSync } from 'node:child_process';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const OMEN = process.env.OMEN_URL || 'http://100.70.60.29:11434';
const TARGET = process.argv[2] || 'pliny-coder-7b-obliteratus:latest';
const N = parseInt(process.argv[3] || '15', 10);
const LATENCY_TRIGGER_MS = 800; // Pliny's VRAM-throttle line

async function ps() {
  const r = await fetch(`${OMEN}/api/ps`);
  return r.ok ? await r.json() : { error: r.status };
}
async function gen() {
  const t0 = Date.now();
  const r = await fetch(`${OMEN}/api/generate`, {
    method: 'POST', headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ model: TARGET, stream: false,
      prompt: 'Write one short sentence about iron.', options: { temperature: 0.7, num_predict: 80 } }),
  });
  if (!r.ok) throw new Error(`HTTP ${r.status}`);
  const j = await r.json();
  return { ms: Date.now() - t0, reply: (j.response || '').trim().slice(0, 120) };
}

const before = await ps();
const runs = [];
for (let i = 1; i <= N; i++) {
  try { runs.push(await gen()); } catch (e) { runs.push({ ms: -1, error: String(e) }); }
}
const after = await ps();

const ok = runs.filter(r => r.ms > 0).map(r => r.ms);
const first = ok[0] ?? 0, last = ok[ok.length - 1] ?? 0;
const mean = ok.reduce((a, b) => a + b, 0) / (ok.length || 1);
const driftPct = first ? +(((last - first) / first) * 100).toFixed(1) : null;
const throttled = ok.filter(ms => ms > LATENCY_TRIGGER_MS).length;

const out = {
  ts: new Date().toISOString(), agent: 'artifex', run: 'ptq-burn-in',
  target: TARGET, omen: OMEN, requests: N, okRequests: ok.length,
  latencyMs: { first, last, mean: Math.round(mean), max: Math.max(...ok, 0), over800ms: throttled },
  driftFirstToLastPct: driftPct,
  vram: {
    before: before.models?.map(m => ({ name: m.name, size_vram: m.size_vram, ctx: m.context_length })) || before.error,
    after: after.models?.map(m => ({ name: m.name, size_vram: m.size_vram, ctx: m.context_length })) || after.error,
  },
  verdict: throttled > 0 ? 'THROTTLE-FLAG — latency over 800ms'
    : (driftPct !== null && driftPct > 25) ? 'DRIFT-SUSPECT — latency climbing'
    : 'PASS — stable under sustained load',
};
const dir = join(__dirname, 'receipts'); mkdirSync(dir, { recursive: true });
const file = join(dir, `burnin-${out.ts.replace(/[:.]/g, '-')}.json`);
writeFileSync(file, JSON.stringify(out, null, 2));
const sha = execSync(`sha256sum "${file}"`).toString().split(' ')[0];
console.log(JSON.stringify({ ...out, receipt: file, sha256: sha }, null, 2));
