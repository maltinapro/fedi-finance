#!/usr/bin/env bash
# Smoke test: PDFCraft /health and POST /v1/invoices with the token from init-pdfcraft-token.sh.
set -euo pipefail

cd "$(dirname "$0")"
port="${PDFCRAFT_PORT:-3000}"
base="http://127.0.0.1:${port}"
token="$(cat .secrets/pdfcraft-token)"
out="$(mktemp)"
trap 'rm -f "$out"' EXIT

curl -fsS "${base}/health"
echo
curl -fsS -X POST "${base}/v1/invoices" \
  -H "X-API-Key: ${token}" \
  -H 'content-type: application/json' \
  --data @pdfcraft-sample-invoice.json -o "$out"
if [ "$(head -c 5 "$out")" != "%PDF-" ]; then
  echo "POST /v1/invoices did not return a PDF" >&2
  exit 1
fi
echo "POST /v1/invoices returned a PDF ($(wc -c <"$out") bytes)"
