#!/usr/bin/env node
/**
 * reset-verifier.mjs — Artifex toolsmith · 2026-09-25
 * Atomic .env reset proof for tribe seats.
 * Law: editing .env changes NOTHING until restart; /proc/environ lies (env-loader).
 * Only honest proof = exercise the seat's health endpoint after restart.
 *
 * Usage: node reset-verifier.mjs <seat-name> [--dry-run]
 * Reads baseline from wave-baseline.json (same dir). Backs up .env before edit.
 */
import fs from "node:fs";
import path from "node:path";
import { execSync } from "node:child_process";

const [seat, ...flags] = process.argv.slice(2);
const DRY = flags.includes("--dry-run");
if (!seat) { console.error("usage: reset-verifier.mjs <seat> [--dry-run]"); process.exit(1); }

const ROOT = "/opt/alloyscape/agents";
const envPath = path.join(ROOT, seat, ".env");
const base = JSON.parse(fs.readFileSync(new URL("./wave-baseline.json", import.meta.url), "utf8"));
const granted = base[seat];
if (!granted) { console.error(`No wave baseline for seat "${seat}". Add it to wave-baseline.json first.`); process.exit(1); }

const health = async () => {
  const port = granted.port;
  try {
    const res = await fetch(`http://127.0.0.1:${port}/health`, { signal: AbortSignal.timeout(4000) });
    const j = await res.json();
    return { ok: true, tools: j.tool_count ?? j.tools?.length ?? null, name: j.name };
  } catch { return { ok: false, tools: null, name: seat }; }
};

console.log(`[reset-verifier] seat=${seat} dry=${DRY}`);
const before = await health();
console.log(`[before] health=${before.ok} tools=${before.tools}`);

if (!fs.existsSync(envPath)) { console.error(`No .env at ${envPath} — nothing to reset.`); process.exit(1); }
const backup = `${envPath}.bak.${Date.now()}`;
if (!DRY) fs.copyFileSync(envPath, backup);
console.log(`[env] backup=${backup} (real copy ${DRY ? "skipped (dry)" : "written"})`);

if (!DRY) {
  fs.writeFileSync(envPath, granted.env.map(([k, v]) => `${k}=${v}`).join("\n") + "\n");
  try { execSync(`pm2 restart ${seat}-think --update-env`, { stdio: "inherit", timeout: 30000 }); }
  catch (e) { console.error(`[restart] FAILED: ${e.message}`); process.exit(1); }
}

await new Promise(r => setTimeout(r, 2500));
const after = await health();
console.log(`[after] health=${after.ok} tools=${after.tools} expected=${granted.expectedTools}`);

const PASS = after.ok && (granted.expectedTools == null || after.tools === granted.expectedTools);
console.log(`[verdict] ${PASS ? "PASS — reset proven by live belt" : "FAIL — belt does not match baseline"}`);
process.exit(PASS ? 0 : 2);
