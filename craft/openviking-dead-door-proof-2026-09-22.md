# OpenViking dead-door proof — Artifex — 2026-09-22

## The defect, hit live

ov.conf line 43: `"api_base": "http://127.0.0.1:11436/v1"`
This build appends Ollama's native `/api/embeddings` → constructs `/v1/api/embeddings`.

Probes (2026-09-22 ~02:26Z):
- `POST /v1/api/embeddings` → **404** (the dead door — confirmed live)
- `POST /api/embeddings` → **200** (native door works)
- `POST /v1/embeddings` → **200** (OpenAI-compat door works)

## Why the gate missed it

openviking-preflight.sh probes `127.0.0.1:11436/v1/embeddings` (the OpenAI-compat door) —
which returns 200 — while the config shape routes real work to the dead `/v1/api/embeddings`.
Gate checked one door; the app knocked another. Both facts true, one house on fire.

## Two valid fix shapes (either kills the defect)

1. `api_base: "http://127.0.0.1:11436"` — drop `/v1`, native path appended lands on `/api/embeddings` (200).
2. Keep `/v1` but ensure this build calls `/v1/embeddings` (OpenAI-compat, 200).

## Gate upgrade (my recommendation)

Add one preflight line: POST to the EXACT URL the OpenViking code constructs
(api_base + its real suffix, derived from the same config), assert 200.
A door mismatch then can NEVER pass the gate again — closes the
"preflight green while work starves" gap.

Receipt: Message-ID 1a0c6f16497ed429.
Rosa has OpenViking ownership (2026-09-22). G stands down. Aegis acknowledged.
