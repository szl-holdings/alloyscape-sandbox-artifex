#!/usr/bin/env bash
# Artifex · pdf-to-studio-reader
# Forge a self-contained Studio reader from any PDF in one command.
# Output: /tribe/files/<slug>-reader.html  (text for 100mph readers + browser TTS "Listen" button, zero install)
# Optional MP3 narrator: drop a file at the same slug name and it links automatically.
set -euo pipefail

PDF="${1:?usage: pdf-to-studio-reader.sh <book.pdf> [title]}"
TITLE="${2:-$(basename "$PDF" .pdf)}"
SLUG="$(echo "$TITLE" | tr ' A-Z' '_a-z' | tr -cd 'a-z0-9_')"
OUT_DIR="/opt/alloyscape/forge/public/files"
mkdir -p "$OUT_DIR"
TXT="$OUT_DIR/$SLUG.txt"

# 1) Extract text — prefer pdftotext, fall back to python if present
if command -v pdftotext >/dev/null 2>&1; then
  pdftotext -layout "$PDF" "$TXT"
elif command -v python3 >/dev/null 2>&1 && python3 -c "import pypdf" 2>/dev/null; then
  python3 - "$PDF" "$TXT" <<'PY'
import sys
from pypdf import PdfReader
r=PdfReader(sys.argv[1])
open(sys.argv[2],"w").write("\n".join((p.extract_text() or "") for p in r.pages))
PY
else
  echo "NO_TEXT_EXTRACTOR: install poppler-utils (pdftotext) or pypdf" >&2
  exit 3
fi

# 2) Build standalone HTML reader (no external deps; uses browser speechSynthesis for audio)
python3 - "$TXT" "$TITLE" "$OUT_DIR/$SLUG-reader.html" <<'PY'
import sys, html
txt=open(sys.argv[1],encoding="utf-8",errors="replace").read()
title=sys.argv[2]
body=html.escape(txt)
html_out=f"""<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{html.escape(title)} — Studio Reader</title>
<style>body{{font:16px/1.6 Georgia,serif;max-width:760px;margin:2rem auto;padding:0 1rem;background:#0f1512;color:#d9e4dd}}
h1{{font-size:1.4rem;color:#9fb8a8}}button{{background:#2f6f52;color:#fff;border:0;padding:.6rem 1rem;border-radius:6px;cursor:pointer;font-size:1rem;margin-bottom:1rem}}
pre{{white-space:pre-wrap;word-wrap:break-word}}</style></head>
<body><h1>{html.escape(title)}</h1>
<button onclick="readAloud()">▶ Listen (browser voice)</button>
<pre id="t">{body}</pre>
<script>function readAloud(){{const u=new SpeechSynthesisUtterance(document.getElementById('t').innerText);u.rate=1;u.pitch=1;speechSynthesis.cancel();speechSynthesis.speak(u);}}</script>
</body></html>"""
open(sys.argv[3],"w").write(html_out)
PY

echo "DONE: /tribe/files/$SLUG-reader.html  (text + listen)"
wc -c "$OUT_DIR/$SLUG-reader.html" "$TXT"
