#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

PACKAGE_ENGINE="${PROJECT_ROOT}/core/deployment-package/engine/create-deployment-package.sh"
TARGET_ENGINE="${PROJECT_ROOT}/core/deployment-target/engine/resolve-deployment-target.sh"
EXECUTOR="${PROJECT_ROOT}/core/deployment-executor/engine/execute-deployment.sh"
VERIFIER="${PROJECT_ROOT}/core/deployment-verification/engine/verify-deployment.sh"
HEALTH_GATE="${PROJECT_ROOT}/core/deployment-verification/engine/health-gate.sh"
ROLLBACK="${PROJECT_ROOT}/core/deployment-rollback/engine/rollback-deployment.sh"

WEBSITE_ID="${1:-}"
ENVIRONMENT="${2:-}"
VERSION="${3:-}"

if [[ -z "${WEBSITE_ID}" || -z "${ENVIRONMENT}" || -z "${VERSION}" ]]; then
    echo "ERROR: Usage: deployment-controller.sh <website_id> <environment> <version>"
    exit 1
fi

PACKAGE="${PROJECT_ROOT}/data/deployment-package/packages/${WEBSITE_ID}/${VERSION}"
TARGET="${PACKAGE}"
DEPLOYMENT="${PROJECT_ROOT}/data/deployment-executor/deployments/${WEBSITE_ID}-${VERSION}-${ENVIRONMENT}"

echo "=== DEPLOYMENT LIFECYCLE CONTROLLER ==="

echo
echo "1. PACKAGE"
"${PACKAGE_ENGINE}" "${WEBSITE_ID}" "${ENVIRONMENT}" "${VERSION}" \
    | grep -q "deployment-package-ready"
echo "PASS: Package"

echo
echo "2. TARGET"
"${TARGET_ENGINE}" "${WEBSITE_ID}" "${ENVIRONMENT}" "${VERSION}" \
    | grep -q "deployment-target-resolved"
echo "PASS: Target"

echo
echo "3. EXECUTE"
"${EXECUTOR}" "${PACKAGE}" "${TARGET}" \
    | grep -q "deployment-complete"
echo "PASS: Execution"

echo
echo "4. VERIFY"

if [[ "${CONTROLLER_INJECT_FAILURE:-}" == "verify" ]]; then
    echo "INJECTED FAILURE: verification"
    VERIFICATION_FAILED=1
else
    VERIFICATION_OUTPUT="$("${VERIFIER}" "${DEPLOYMENT}")"

    if printf '%s\n' "${VERIFICATION_OUTPUT}" \
        | grep -q "deployment-verified"; then
        VERIFICATION_FAILED=0
    else
        VERIFICATION_FAILED=1
    fi
fi

if [[ "${VERIFICATION_FAILED}" -eq 1 ]]; then
    echo "FAIL: Verification"
    echo "ACTION: Rollback"

    ROLLBACK_OUTPUT="$("${ROLLBACK}" "${DEPLOYMENT}")"

    printf '%s\n' "${ROLLBACK_OUTPUT}" \
        | grep -q "deployment-rollback-complete"

    echo "PASS: Rollback"
    echo "lifecycle_status=rolled_back"
    exit 1
fi

echo "PASS: Verification"

echo
echo "5. HEALTH GATE"

if [[ "${CONTROLLER_INJECT_FAILURE:-}" == "health" ]]; then
    echo "INJECTED FAILURE: health gate"
    HEALTH_FAILED=1
else
    HEALTH_OUTPUT="$("${HEALTH_GATE}" "${DEPLOYMENT}")"

    if printf '%s\n' "${HEALTH_OUTPUT}" \
        | grep -q "health-gate-passed"; then
        HEALTH_FAILED=0
    else
        HEALTH_FAILED=1
    fi
fi

if [[ "${HEALTH_FAILED}" -eq 1 ]]; then
    echo "FAIL: Health Gate"
    echo "ACTION: Rollback"

    ROLLBACK_OUTPUT="$("${ROLLBACK}" "${DEPLOYMENT}")"

    printf '%s\n' "${ROLLBACK_OUTPUT}" \
        | grep -q "deployment-rollback-complete"

    echo "PASS: Rollback"
    echo "lifecycle_status=rolled_back"
    exit 1
fi

echo "PASS: Health Gate"

echo
echo "=== DEPLOYMENT LIFECYCLE COMPLETE ==="
echo "deployment_id=$(basename "${DEPLOYMENT}")"
echo "lifecycle_status=complete"
