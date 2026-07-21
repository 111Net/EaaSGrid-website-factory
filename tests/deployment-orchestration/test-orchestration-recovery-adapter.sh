#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

ADAPTER="${PROJECT_ROOT}/core/deployment-orchestration/adapters/orchestration-recovery-adapter.sh"

WEBSITE_ID="week8-day2-test"
ENVIRONMENT="staging"
VERSION="v1.0.0"

echo "=== ORCHESTRATION RECOVERY ADAPTER TEST ==="

############################################################
# SUCCESS PATH
############################################################

OUTPUT="$(
    "${ADAPTER}" \
        "${WEBSITE_ID}" \
        "${ENVIRONMENT}" \
        "${VERSION}"
)"

printf '%s\n' "${OUTPUT}" | grep -q "deployment-lifecycle-adapter-complete"

echo "PASS: Lifecycle adapter completed"

printf '%s\n' "${OUTPUT}" | grep -q "lifecycle_status=complete"

echo "PASS: Lifecycle completed"

printf '%s\n' "${OUTPUT}" | grep -q "recovery_required=false"

echo "PASS: Recovery not required"

############################################################
# FAILURE PATH
############################################################

set +e

OUTPUT="$(
    CONTROLLER_INJECT_FAILURE=verify \
    "${ADAPTER}" \
        "${WEBSITE_ID}-failure" \
        "${ENVIRONMENT}" \
        "${VERSION}" 2>&1
)"

RC=$?

set -e

test "${RC}" -ne 0

echo "PASS: Failure detected"

printf '%s\n' "${OUTPUT}" | grep -q "Lifecycle failed."

echo "PASS: Lifecycle rollback executed"

printf '%s\n' "${OUTPUT}" | grep -q "Starting orchestration recovery"

echo "PASS: Recovery started"

printf '%s\n' "${OUTPUT}" | grep -q "recovery_required=true"

echo "PASS: Recovery required"

echo
echo "PASS: Orchestration Recovery Adapter"
