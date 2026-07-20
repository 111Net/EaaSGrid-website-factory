#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

EXECUTOR="${PROJECT_ROOT}/core/deployment-orchestration/engine/execute-orchestration-plan.sh"

PLAN_FILE="${PROJECT_ROOT}/data/deployment-orchestration/test-execution-plan.json"

mkdir -p "$(dirname "${PLAN_FILE}")"

cat > "${PLAN_FILE}" <<'JSON'
{
  "orchestration_id": "test-orchestration",
  "execution_order": [
    "package",
    "target",
    "execute",
    "verify",
    "health_gate"
  ]
}
JSON

echo "=== SUCCESS PATH ==="

SUCCESS_OUTPUT="$("${EXECUTOR}" "${PLAN_FILE}")"

printf '%s\n' "${SUCCESS_OUTPUT}" \
    | grep -q "STATE: ORCHESTRATION_COMPLETED"

printf '%s\n' "${SUCCESS_OUTPUT}" \
    | grep -q "orchestration_status=complete"

echo "PASS: Successful orchestration execution"

echo
echo "=== FAILURE PATH ==="

set +e

FAILURE_OUTPUT="$(
    ORCHESTRATION_FAIL_STAGE="verify" \
    "${EXECUTOR}" "${PLAN_FILE}" 2>&1
)"

FAILURE_CODE=$?

set -e

if [[ "${FAILURE_CODE}" -eq 0 ]]; then
    echo "FAIL: Failure path returned success"
    exit 1
fi

printf '%s\n' "${FAILURE_OUTPUT}" \
    | grep -q "FAIL: Stage verify"

echo "PASS: Failure stage detected"

printf '%s\n' "${FAILURE_OUTPUT}" \
    | grep -q "STATE: ORCHESTRATION_FAILED"

echo "PASS: Orchestration failure state"

printf '%s\n' "${FAILURE_OUTPUT}" \
    | grep -q "failed_stage=verify"

echo "PASS: Failed stage recorded"

printf '%s\n' "${FAILURE_OUTPUT}" \
    | grep -q "orchestration_status=failed"

echo "PASS: Failure status recorded"

if printf '%s\n' "${FAILURE_OUTPUT}" \
    | grep -q "STAGE 5: health_gate"; then
    echo "FAIL: Execution continued after failure"
    exit 1
fi

echo "PASS: Execution halted after failure"

rm -f "${PLAN_FILE}"

echo
echo "PASS: Deployment Orchestration Failure Handling"
