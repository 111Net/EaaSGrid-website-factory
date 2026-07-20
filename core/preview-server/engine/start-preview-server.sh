#!/usr/bin/env bash
set -Eeuo pipefail

OUTPUT_ROOT="${1:-}"
HOST="${2:-127.0.0.1}"
PORT="${3:-8765}"

if [[ -z "${OUTPUT_ROOT}" ]]; then
    echo "ERROR: Website output path is required" >&2
    exit 1
fi

if [[ ! -d "${OUTPUT_ROOT}" ]]; then
    echo "ERROR: Website output does not exist: ${OUTPUT_ROOT}" >&2
    exit 1
fi

"${PWD}/core/static-runtime/engine/validate-static-website.sh" \
    "${OUTPUT_ROOT}" >/dev/null

echo "Starting preview server"
echo "Host: ${HOST}"
echo "Port: ${PORT}"
echo "Output: ${OUTPUT_ROOT}"

exec python3 -m http.server \
    "${PORT}" \
    --bind "${HOST}" \
    --directory "${OUTPUT_ROOT}"
