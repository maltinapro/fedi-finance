#!/usr/bin/env bash
# Creates a PDFCraft token for local development and stores it in deploy/dev/.secrets/pdfcraft-token.
# The token is shown only once by PDFCraft, so an existing token file is kept.
set -euo pipefail

cd "$(dirname "$0")"
port="${PDFCRAFT_PORT:-3000}"
token_file=".secrets/pdfcraft-token"

for _ in $(seq 1 60); do
  if curl -fsS "http://127.0.0.1:${port}/health" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 1
done
if [ "${ready:-0}" != "1" ]; then
  echo "PDFCraft did not become healthy on port ${port}" >&2
  exit 1
fi

if [ -s "$token_file" ]; then
  echo "PDFCraft token already exists: deploy/dev/${token_file}"
  exit 0
fi

output="$(docker compose exec -T pdfcraft /app/pdfcraft-backend tokens create --plan starter --days 365)"
token="$(printf '%s\n' "$output" | grep -oE 'pk_[A-Za-z0-9_-]+' | head -n 1 || true)"
if [ -z "$token" ]; then
  echo "Could not find a token in the output of 'pdfcraft-backend tokens create':" >&2
  printf '%s\n' "$output" >&2
  exit 1
fi

mkdir -p .secrets
umask 077
printf '%s\n' "$token" >"$token_file"
echo "PDFCraft token written to deploy/dev/${token_file}"
