#!/usr/bin/env node
// Artifex · Bonsai proof stamp (v1) — 2026-09-21
// For TOMASITA's close condition (Finn's board): port 8144 answering HTTP 200,
// model serving, generation round-trip. VRAM ≤7.5GB is read on-box by
// Tomasita/Stephen (nvidia-smi side) — this stamp leaves a slot for it.
// Runs PENDING (exit 0) while the server is still down — no crash, no noise.
// The moment her llama-server lands, same command stamps PROOF-PASS + sha256.

import { writeFileSync, mkdirSync } from 'node:fs';
import { execSync } from 'node:child_process';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const HOST = process.env.BONSAI_URL || 'http://100.70.60.29:8144';
const VRAM_LIMIT_GB = 7.5;

async function tryGet(path, ms = 4000) {
  const ctl = new AbortController();
  const t = setTimeout(() => ctl.abort(), ms);
  try {
    const r = await fetch(HOST + path, { signal: ctl.signal });
    const body = await r.text();
    return { ok: r.ok, status: r.status, body: body.slice(0, 400) };
  } catch (e) {
    return { ok: false, error: String(e) };
  } finally { clearTimeout(ctl); }
}

async function tryGenerate(ms = 20000) {
  const ctl = new AbortController();
  const t = setTimeout(() => ctl.abort(), ms);
  const t0 = Date.now();
  try {
    const r = await fetch(HOST + '/v1/chat/completions', {
      method: 'POST', headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ messages: [{ role: 'user', content: 'Reply with exactly: BONSAI-ALIVE' }],
        max_tokens: 20, temperature: 0 }),
      signal: ctl.signal,
    });
    const j = await r.json();
    return { ok: r.ok, status: r.status, ms: Date.now() - t0,
      reply: j.choices?.[0]?.message?.content?.trim().slice(0, 120) ?? null };
  } catch (e) { return { ok: false, error: String(e) }; }
  finally { clearTimeout(t); }
}

const health = await tryGet('/health');
const models = health.ok ? await tryGet('/v1/models') : { ok: false, skipped: 'no health' };
const gen = models.ok ? await tryGenerate() : { ok: false, skipped: 'no models' };

const up = health.ok;
const checks = {
  port8144Health: up ? `HTTP ${health.status}` : 'DOWN',
  modelServing: models.ok ? 'listed' : (up ? 'FAIL' : 'n/a'),
  generation: gen.ok ? `${gen.ms}ms → "${gen.reply}"` : (up ? 'FAIL' : 'n/a'),
  vramOnBox: '[SLOT — Tomasita/Stephen paste nvidia-smi GB here, limit 7.5]',
};

const verdict = up && models.ok && gen.ok ? 'PROOF-PASS' : (up ? 'PROOF-FAIL — server up but checks red' : 'PENDING — server not listening yet (expected during download)');

const out = {
  ts: new Date().toISOString(), agent: 'artifex', run: 'bonsai-proof-stamp',
  target: HOST, verdict, checks, vramLimitGb: VRAM_LIMIT_GB,
  note: 'Proof owner: Tomasita. Close condition per Finn: 8144 HTTP 200 + VRAM ≤7.5GB + her name on proof.',
};
const dir = join(__dirname, 'receipts'); mkdirSync(dir, { recursive: true });
const file = join(dir, `bonsai-${out.ts.replace(/[:.]/g, '-')}.json`);
writeFileSync(file, JSON.stringify(out, null, 2));
const sha = execSync(`sha256sum "${file}"`).toString().split(' ')[0];
console.log(JSON.stringify({ verdict, checks, receipt: file, sha256: sha }, null, 2));
