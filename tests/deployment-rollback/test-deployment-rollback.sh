#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PACKAGE_ENGINE="${PROJECT_ROOT}/core/deployment-package/engine/create-deployment-package.sh"
TARGET_ENGINE="${PROJECT_ROOT}/core/deployment-target/engine/resolve-deployment-target.sh"
EXECUTOR="${PROJECT_ROOT}/core/deployment-executor/engine/execute-deployment.sh"
VERIFIER="${PROJECT_ROOT}/core/deployment-verification/engine/verify-deployment.sh"
ROLLBACK="${PROJECT_ROOT}/core/deployment-rollback/engine/rollback-deployment.sh"

PACKAGE="${PROJECT_ROOT}/data/deployment-package/packages/test-rollback-website/v1.0.0"
TARGET="${PROJECT_ROOT}/data/deployment-package/packages/test-rollback-website/v1.0.0"
DEPLOYMENT="${PROJECT_ROOT}/data/deployment-executor/deployments/test-rollback-website-v1.0.0-staging"

rm -rf \
    "${PROJECT_ROOT}/data/deployment-package/packages/test-rollback-website" \
    "${DEPLOYMENT}"

echo "=== DEPLOYMENT ROLLBACK TESTS ==="

"${PACKAGE_ENGINE}" test-rollback-website staging v1.0.0 \
    | grep -q "deployment-package-ready"

echo "PASS: Deployment package dependency"

"${TARGET_ENGINE}" test-rollback-website staging v1.0.0 \
    | grep -q "deployment-target-resolved"

echo "PASS: Deployment target dependency"

"${EXECUTOR}" "${PACKAGE}" "${TARGET}" \
    | grep -q "deployment-complete"

echo "PASS: Deployment execution"

VERIFICATION_OUTPUT="$("${VERIFIER}" "${DEPLOYMENT}")"

printf '%s\n' "${VERIFICATION_OUTPUT}"     | grep -q "deployment-verified"

echo "PASS: Deployment verification"

ROLLBACK_OUTPUT="$("${ROLLBACK}" "${DEPLOYMENT}")"

printf '%s\n' "${ROLLBACK_OUTPUT}" \
    | grep -q "deployment-rollback-complete"

echo "PASS: Deployment rollback"

printf '%s\n' "${ROLLBACK_OUTPUT}" \
    | grep -q "rollback_status=rolled_back"

echo "PASS: Rollback status"

python3 - "${DEPLOYMENT}/deployment-record.json" <<'PY'
import json
import sys
from pathlib import Path

record = json.loads(Path(sys.argv[1]).read_text())

if record["deployment_status"] != "rolled_back":
    raise SystemExit("ERROR: Deployment was not rolled back")

print("PASS: Rollback record state")
PY

echo
echo "PASS: Deployment Rollback Engine"
