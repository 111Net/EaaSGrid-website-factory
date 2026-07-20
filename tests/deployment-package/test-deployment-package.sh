#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PACKAGE_ENGINE="${PROJECT_ROOT}/core/deployment-package/engine/create-deployment-package.sh"
VALIDATOR="${PROJECT_ROOT}/core/deployment-package/engine/validate-deployment-package.sh"

TEST_PACKAGE="${PROJECT_ROOT}/data/deployment-package/packages/test-website/v1.0.0"

rm -rf "${PROJECT_ROOT}/data/deployment-package/packages/test-website"

echo "=== DEPLOYMENT PACKAGE ENGINE TESTS ==="

"${PACKAGE_ENGINE}" test-website staging v1.0.0 \
    | grep -q "deployment-package-ready"

echo "PASS: Deployment package creation"

[[ -f "${TEST_PACKAGE}/deployment-manifest.json" ]]

echo "PASS: Deployment manifest"

"${VALIDATOR}" "${TEST_PACKAGE}" | grep -q "valid"

echo "PASS: Valid deployment package"

if "${PACKAGE_ENGINE}" invalid-website invalid-environment v1.0.0 >/dev/null 2>&1; then
    echo "FAIL: Invalid environment accepted"
    exit 1
fi

echo "PASS: Invalid environment rejection"

python3 - <<PY
import json
from pathlib import Path

files = [
    Path("${PROJECT_ROOT}/data/deployment-package/packages/test-website/v1.0.0/deployment-manifest.json"),
    Path("${PROJECT_ROOT}/schemas/deployment-package/deployment-package.schema.json")
]

for file in files:
    json.loads(file.read_text())
    print(f"PASS: {file}")

print(f"PASS: {len(files)} JSON files validated")
PY

echo
echo "PASS: Deployment Package Engine"
