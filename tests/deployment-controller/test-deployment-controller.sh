#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

CONTROLLER="${PROJECT_ROOT}/core/deployment-controller/engine/deployment-controller.sh"

WEBSITE_ID="test-controller-website"
ENVIRONMENT="staging"
VERSION="v1.0.0"

PACKAGE="${PROJECT_ROOT}/data/deployment-package/packages/${WEBSITE_ID}/${VERSION}"
DEPLOYMENT="${PROJECT_ROOT}/data/deployment-executor/deployments/${WEBSITE_ID}-${VERSION}-${ENVIRONMENT}"

rm -rf \
    "${PACKAGE%/${VERSION}}" \
    "${DEPLOYMENT}"

echo "=== DEPLOYMENT CONTROLLER TESTS ==="

CONTROLLER_OUTPUT="$(
    "${CONTROLLER}" \
        "${WEBSITE_ID}" \
        "${ENVIRONMENT}" \
        "${VERSION}"
)"

printf '%s\n' "${CONTROLLER_OUTPUT}" \
    | grep -q "PASS: Package"
echo "PASS: Controller package stage"

printf '%s\n' "${CONTROLLER_OUTPUT}" \
    | grep -q "PASS: Target"
echo "PASS: Controller target stage"

printf '%s\n' "${CONTROLLER_OUTPUT}" \
    | grep -q "PASS: Execution"
echo "PASS: Controller execution stage"

printf '%s\n' "${CONTROLLER_OUTPUT}" \
    | grep -q "PASS: Verification"
echo "PASS: Controller verification stage"

printf '%s\n' "${CONTROLLER_OUTPUT}" \
    | grep -q "PASS: Health Gate"
echo "PASS: Controller health-gate stage"

printf '%s\n' "${CONTROLLER_OUTPUT}" \
    | grep -q "lifecycle_status=complete"
echo "PASS: Lifecycle completion state"

echo
echo "PASS: Deployment Lifecycle Controller"

rm -rf \
    "${PACKAGE%/${VERSION}}" \
    "${DEPLOYMENT}"
