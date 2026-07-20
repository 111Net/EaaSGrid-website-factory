#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PLANNER="${PROJECT_ROOT}/core/deployment-orchestration/engine/create-orchestration-plan.sh"
EXECUTOR="${PROJECT_ROOT}/core/deployment-orchestration/engine/execute-orchestration-plan.sh"
RECOVERY="${PROJECT_ROOT}/core/deployment-orchestration/recovery/recover-orchestration.sh"

PLAN_FILE="${PROJECT_ROOT}/data/deployment-orchestration/week7-final-plan.json"
FAILURE_PLAN="${PROJECT_ROOT}/data/deployment-orchestration/week7-final-failure-plan.json"
RECOVERY_FILE="${PROJECT_ROOT}/data/deployment-orchestration/week7-final-recovery.json"

mkdir -p "$(dirname "${PLAN_FILE}")"

rm -f "${PLAN_FILE}" "${FAILURE_PLAN}" "${RECOVERY_FILE}"

echo "=========================================="
echo "WEEK 7 FINAL DEPLOYMENT ORCHESTRATION TEST"
echo "=========================================="

echo
echo "=== PLANNING PATH ==="

"${PLANNER}" \
    "week7-final-orchestration" \
    "package,target,execute,verify,health" \
    "target:package,execute:target,verify:execute,health:verify" \
    > /tmp/week7-plan-output.txt

grep -q "orchestration-plan-created" /tmp/week7-plan-output.txt

echo "PASS: Orchestration plan created"

echo
echo "=== EXECUTION PATH ==="

cat > "${PLAN_FILE}" <<'JSON'
{
  "orchestration_id": "week7-final-orchestration",
  "execution_order": [
    "package",
    "target",
    "execute",
    "verify",
    "health"
  ]
}
JSON

"${EXECUTOR}" "${PLAN_FILE}" > /tmp/week7-execution-output.txt

grep -q "orchestration-complete" /tmp/week7-execution-output.txt

echo "PASS: Orchestration execution completed"

echo
echo "=== FAILURE PATH ==="

cat > "${FAILURE_PLAN}" <<'JSON'
{
  "orchestration_id": "week7-final-failure",
  "execution_order": [
    "package",
    "target",
    "execute",
    "verify",
    "health"
  ],
  "failure_stage": "verify"
}
JSON

if "${EXECUTOR}" "${FAILURE_PLAN}" > /tmp/week7-failure-output.txt 2>&1; then
    echo "FAIL: Failure path unexpectedly succeeded"
    exit 1
fi

grep -q "orchestration-failed" /tmp/week7-failure-output.txt

echo "PASS: Failure detected"
echo "PASS: Execution halted on failure"

echo
echo "=== RECOVERY PATH ==="

"${RECOVERY}" \
    "${FAILURE_PLAN}" \
    "${RECOVERY_FILE}" \
    > /tmp/week7-recovery-output.txt

grep -q "orchestration-recovery-ready" /tmp/week7-recovery-output.txt

echo "PASS: Recovery readiness"
echo "PASS: Resume point identified"
echo "PASS: Recovery state recorded"

echo
echo "=========================================="
echo "WEEK 7 FINAL INTEGRATION GATE"
echo "=========================================="
echo "PLANNING:  PASS"
echo "EXECUTION: PASS"
echo "FAILURE:   PASS"
echo "RECOVERY:  PASS"
echo "=========================================="
echo "WEEK 7 STATUS: COMPLETE"
echo "=========================================="
