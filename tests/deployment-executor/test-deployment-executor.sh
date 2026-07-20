#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PACKAGE_ENGINE="${PROJECT_ROOT}/core/deployment-package/engine/create-deployment-package.sh"
TARGET_ENGINE="${PROJECT_ROOT}/core/deployment-target/engine/resolve-deployment-target.sh"
EXECUTOR="${PROJECT_ROOT}/core/deployment-executor/engine/execute-deployment.sh"
VALIDATOR="${PROJECT_ROOT}/core/deployment-executor/engine/validate-deployment.sh"

PACKAGE="${PROJECT_ROOT}/data/deployment-package/packages/test-executor-website/v1.0.0"
TARGET="${PROJECT_ROOT}/data/deployment-package/packages/test-executor-website/v1.0.0"
DEPLOYMENT="${PROJECT_ROOT}/data/deployment-executor/deployments/test-executor-website-v1.0.0-staging"

rm -rf \
    "${PROJECT_ROOT}/data/deployment-package/packages/test-executor-website" \
    "${DEPLOYMENT}"

echo "=== DEPLOYMENT EXECUTOR TESTS ==="

"${PACKAGE_ENGINE}" test-executor-website staging v1.0.0 \
    | grep -q "deployment-package-ready"

echo "PASS: Deployment package dependency"

"${TARGET_ENGINE}" test-executor-website staging v1.0.0 \
    | grep -q "deployment-target-resolved"

echo "PASS: Deployment target dependency"

"${EXECUTOR}" "${PACKAGE}" "${TARGET}" \
    | grep -q "deployment-complete"

echo "PASS: Deployment execution"

[[ -f "${DEPLOYMENT}/deployment-record.json" ]]

echo "PASS: Deployment record"

"${VALIDATOR}" "${DEPLOYMENT}" | grep -q "valid"

echo "PASS: Valid deployment"

python3 - <<PY
import json
from pathlib import Path

files = [
    Path("${DEPLOYMENT}/deployment-record.json"),
    Path("${PROJECT_ROOT}/schemas/deployment-executor/deployment-executor.schema.json")
]

for file in files:
    json.loads(file.read_text())
    print(f"PASS: {file}")

print(f"PASS: {len(files)} JSON files validated")
PY

echo
echo "PASS: Deployment Executor"
