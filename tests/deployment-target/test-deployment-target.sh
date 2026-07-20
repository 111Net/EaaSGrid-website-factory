#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PACKAGE_ENGINE="${PROJECT_ROOT}/core/deployment-package/engine/create-deployment-package.sh"
TARGET_ENGINE="${PROJECT_ROOT}/core/deployment-target/engine/resolve-deployment-target.sh"
TARGET_VALIDATOR="${PROJECT_ROOT}/core/deployment-target/engine/validate-deployment-target.sh"

WEBSITE_ID="test-target-website"
VERSION="v1.0.0"
ENVIRONMENT="staging"

PACKAGE_ROOT="${PROJECT_ROOT}/data/deployment-package/packages/${WEBSITE_ID}/${VERSION}"
TARGET_FILE="${PACKAGE_ROOT}/deployment-target.json"

rm -rf "${PROJECT_ROOT}/data/deployment-package/packages/${WEBSITE_ID}"

echo "=== DEPLOYMENT TARGET MANAGER TESTS ==="

"${PACKAGE_ENGINE}" "${WEBSITE_ID}" "${ENVIRONMENT}" "${VERSION}" \
    | grep -q "deployment-package-ready"

echo "PASS: Deployment package dependency"

"${TARGET_ENGINE}" "${WEBSITE_ID}" "${ENVIRONMENT}" "${VERSION}" \
    | grep -q "deployment-target-resolved"

echo "PASS: Deployment target resolution"

[[ -f "${TARGET_FILE}" ]]

echo "PASS: Deployment target manifest"

"${TARGET_VALIDATOR}" "${TARGET_FILE}" | grep -q "valid"

echo "PASS: Valid deployment target"

if "${TARGET_ENGINE}" "${WEBSITE_ID}" "invalid-environment" "${VERSION}" >/dev/null 2>&1; then
    echo "FAIL: Invalid environment accepted"
    exit 1
fi

echo "PASS: Invalid environment rejection"

python3 - <<PY
import json
from pathlib import Path

files = [
    Path("${PROJECT_ROOT}/data/deployment-target/targets/target-registry.json"),
    Path("${TARGET_FILE}"),
    Path("${PROJECT_ROOT}/schemas/deployment-target/deployment-target.schema.json")
]

for file in files:
    json.loads(file.read_text())
    print(f"PASS: {file}")

print(f"PASS: {len(files)} JSON files validated")
PY

echo
echo "PASS: Deployment Target Manager"
