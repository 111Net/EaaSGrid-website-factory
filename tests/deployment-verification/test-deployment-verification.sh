#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PACKAGE_ENGINE="${PROJECT_ROOT}/core/deployment-package/engine/create-deployment-package.sh"
TARGET_ENGINE="${PROJECT_ROOT}/core/deployment-target/engine/resolve-deployment-target.sh"
EXECUTOR="${PROJECT_ROOT}/core/deployment-executor/engine/execute-deployment.sh"
VERIFIER="${PROJECT_ROOT}/core/deployment-verification/engine/verify-deployment.sh"
HEALTH_GATE="${PROJECT_ROOT}/core/deployment-verification/engine/health-gate.sh"

PACKAGE="${PROJECT_ROOT}/data/deployment-package/packages/test-verification-website/v1.0.0"
TARGET="${PROJECT_ROOT}/data/deployment-package/packages/test-verification-website/v1.0.0"
DEPLOYMENT="${PROJECT_ROOT}/data/deployment-executor/deployments/test-verification-website-v1.0.0-staging"

rm -rf \
    "${PROJECT_ROOT}/data/deployment-package/packages/test-verification-website" \
    "${DEPLOYMENT}"

echo "=== DEPLOYMENT VERIFICATION TESTS ==="

"${PACKAGE_ENGINE}" test-verification-website staging v1.0.0 \
    | grep -q "deployment-package-ready"

echo "PASS: Deployment package dependency"

"${TARGET_ENGINE}" test-verification-website staging v1.0.0 \
    | grep -q "deployment-target-resolved"

echo "PASS: Deployment target dependency"

"${EXECUTOR}" "${PACKAGE}" "${TARGET}" \
    | grep -q "deployment-complete"

echo "PASS: Deployment execution"

VERIFICATION_OUTPUT="$("${VERIFIER}" "${DEPLOYMENT}")"

printf '%s\n' "${VERIFICATION_OUTPUT}"     | grep -q "deployment-verified"

echo "PASS: Deployment verification"

HEALTH_GATE_OUTPUT="$("${HEALTH_GATE}" "${DEPLOYMENT}")"

printf '%s\n' "${HEALTH_GATE_OUTPUT}"     | grep -q "health-gate-passed"

echo "PASS: Health gate"

echo
echo "PASS: Deployment Verification and Health Gate"
