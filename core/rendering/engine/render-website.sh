#!/usr/bin/env bash
set -Eeuo pipefail

CLIENT_ID="${1:-}"

if [[ -z "${CLIENT_ID}" ]]; then
    echo "ERROR: Client ID is required"
    exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CLIENT_ROOT="${PROJECT_ROOT}/clients/${CLIENT_ID}"
BUILD_ROOT="${CLIENT_ROOT}/build"
RENDER_ROOT="${CLIENT_ROOT}/generated/rendered"

if [[ ! -d "${CLIENT_ROOT}" ]]; then
    echo "ERROR: Client project not found: ${CLIENT_ID}"
    exit 1
fi

mkdir -p "${RENDER_ROOT}"

cat > "${RENDER_ROOT}/rendering-manifest.json" <<JSON
{
  "client_id": "${CLIENT_ID}",
  "renderer": "generic",
  "status": "initialized",
  "layers": [
    "website",
    "page",
    "section",
    "component",
    "theme"
  ]
}
JSON

echo "Rendering architecture initialized: ${CLIENT_ID}"
echo "Render root: ${RENDER_ROOT}"
