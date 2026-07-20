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

echo "=== DEPLOYMENT ORCHESTRATION EXECUTION TESTS ==="

OUTPUT="$("${EXECUTOR}" "${PLAN_FILE}")"

printf '%s\n' "${OUTPUT}" | grep -q "STAGE 1: package"
echo "PASS: Package stage executed"

printf '%s\n' "${OUTPUT}" | grep -q "STAGE 2: target"
echo "PASS: Target stage executed"

printf '%s\n' "${OUTPUT}" | grep -q "STAGE 3: execute"
echo "PASS: Execute stage executed"

printf '%s\n' "${OUTPUT}" | grep -q "STAGE 4: verify"
echo "PASS: Verify stage executed"

printf '%s\n' "${OUTPUT}" | grep -q "STAGE 5: health_gate"
echo "PASS: Health gate stage executed"

printf '%s\n' "${OUTPUT}" \
    | grep -q "STATE: ORCHESTRATION_COMPLETED"

echo "PASS: Orchestration completion state"

printf '%s\n' "${OUTPUT}" \
    | grep -q "orchestration_status=complete"

echo "PASS: Orchestration execution"

rm -f "${PLAN_FILE}"

echo
echo "PASS: Deployment Orchestration Execution"
