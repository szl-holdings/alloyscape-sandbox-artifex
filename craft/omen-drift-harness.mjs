#!/usr/bin/env node
// Artifex · Omen drift-eval harness (scaffold v0.1) — 2026-09-21
// Purpose: give Delphina's drift thresholds a machine-checkable rail.
//   watch triggers (Delphina's plan, muai6uql): retrieval spread σ > 0.15,
//   aggregate coherence decay ∆ > 10%.
// Wiring needs she named: omen_output_stream access, /api/tribe-memory/diff.
// This scaffold consumes a JSON stream file OR a diff endpoint and stamps a
// receipt to disk. Until Omen stream access is granted, it runs in dry mode
// against a local sample so the rail is provable today, not promised.

import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'node:fs';
import { execSync } from 'node:child_process';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const THRESHOLDS = { spread: 0.15, coherenceDrop: 0.10 }; // from Delphina's plan

function mean(xs) { return xs.reduce((a, b) => a + b, 0) / (xs.length || 1); }
function stddev(xs) {
  const m = mean(xs);
  return Math.sqrt(mean(xs.map(x => (x - m) ** 2)));
}

// sample: last N reply similarity scores (placeholder stream until Omen wired)
const SAMPLE = process.argv[2];
let payload;
if (SAMPLE && existsSync(SAMPLE)) {
  payload = JSON.parse(readFileSync(SAMPLE, 'utf8'));
} else {
  // dry-mode sample: two reply-embedding-similarity batches (pre vs post train)
  payload = {
    pre:  [0.82, 0.85, 0.79, 0.84, 0.81, 0.83, 0.86, 0.80],
    post: [0.84, 0.71, 0.86, 0.66, 0.83, 0.55, 0.87, 0.72],
  };
}

const preSd = stddev(payload.pre);
const postSd = stddev(payload.post);
const preMean = mean(payload.pre);
const postMean = mean(payload.post);
const coherenceDelta = (preMean - postMean) / preMean;

const findings = {
  ts: new Date().toISOString(),
  agent: 'artifex',
  mode: SAMPLE ? 'stream' : 'dry-sample',
  thresholds: THRESHOLDS,
  spread: { preSd: +preSd.toFixed(4), postSd: +postSd.toFixed(4),
            tripped: postSd > THRESHOLDS.spread },
  coherence: { preMean: +preMean.toFixed(4), postMean: +postMean.toFixed(4),
               deltaPct: +(coherenceDelta * 100).toFixed(2),
               tripped: coherenceDelta > THRESHOLDS.coherenceDrop },
};
findings.verdict = (findings.spread.tripped || findings.coherence.tripped)
  ? 'DRIFT-SUSPECT — escalate to Delphina + Pliny'
  : 'NO-DRIFT — within thresholds';

const outDir = join(__dirname, 'receipts');
mkdirSync(outDir, { recursive: true });
const out = join(outDir, `drift-${findings.ts.replace(/[:.]/g, '-')}.json`);
writeFileSync(out, JSON.stringify(findings, null, 2));

const sha = execSync(`sha256sum ${out}`).toString().split(' ')[0];
console.log(JSON.stringify({ ...findings, receipt: out, sha256: sha }, null, 2));
