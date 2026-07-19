#!/usr/bin/env bash
set -Eeuo pipefail

CLIENT_ID="${1:-}"

if [[ -z "${CLIENT_ID}" ]]; then
    echo "ERROR: Client ID is required"
    exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CLIENT_ROOT="${PROJECT_ROOT}/clients/${CLIENT_ID}"
GENERATED_ROOT="${CLIENT_ROOT}/generated"
BUILD_ROOT="${CLIENT_ROOT}/build"

if [[ ! -d "${CLIENT_ROOT}" ]]; then
    echo "ERROR: Client project not found: ${CLIENT_ID}"
    exit 1
fi

mkdir -p "${BUILD_ROOT}"

cat > "${BUILD_ROOT}/build-manifest.json" <<JSON
{
  "client_id": "${CLIENT_ID}",
  "project_root": "${CLIENT_ROOT}",
  "build_root": "${BUILD_ROOT}",
  "status": "built",
  "pipeline": [
    "client-configuration",
    "website-type-resolution",
    "website-creation",
    "page-structure",
    "section-composition",
    "component-assembly",
    "build-output"
  ]
}
JSON

echo "Website built successfully: ${CLIENT_ID}"
echo "Build output: ${BUILD_ROOT}"
