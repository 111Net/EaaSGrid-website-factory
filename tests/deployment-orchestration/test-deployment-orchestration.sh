#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

ORCHESTRATOR="${PROJECT_ROOT}/core/deployment-orchestration/engine/orchestrate-deployment.sh"

WEBSITE_ID="week7-orchestration-test"
ENVIRONMENT="staging"
VERSION="v1.0.0"

DEPLOYMENT="${PROJECT_ROOT}/data/deployment-executor/deployments/${WEBSITE_ID}-${VERSION}-${ENVIRONMENT}"
PACKAGE="${PROJECT_ROOT}/data/deployment-package/packages/${WEBSITE_ID}"

AUDIT="${PROJECT_ROOT}/data/deployment-audit/${WEBSITE_ID}-${VERSION}-${ENVIRONMENT}.json"

rm -rf \
    "${DEPLOYMENT}" \
    "${PACKAGE}" \
    "${AUDIT}"

echo "=========================================="
echo "DEPLOYMENT ORCHESTRATION TEST"
echo "=========================================="

OUTPUT="$(
    "${ORCHESTRATOR}" \
        "${WEBSITE_ID}" \
        "${ENVIRONMENT}" \
        "${VERSION}"
)"

printf '%s\n' "${OUTPUT}" \
    | grep -q "ORCHESTRATION: STARTED"

echo "PASS: Orchestration started"

printf '%s\n' "${OUTPUT}" \
    | grep -q "ORCHESTRATION: COMPLETED"

echo "PASS: Orchestration completed"

printf '%s\n' "${OUTPUT}" \
    | grep -q "orchestration_status=complete"

echo "PASS: Orchestration status"

[[ -f "${AUDIT}" ]] \
    && echo "PASS: Audit generated" \
    || {
        echo "FAIL: Audit missing"
        exit 1
    }

rm -rf \
    "${DEPLOYMENT}" \
    "${PACKAGE}" \
    "${AUDIT}"

echo
echo "PASS: Deployment Orchestration Foundation"
