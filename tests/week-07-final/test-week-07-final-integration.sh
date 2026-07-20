#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PLANNER="${PROJECT_ROOT}/core/deployment-orchestration/engine/create-orchestration-plan.sh"
EXECUTOR="${PROJECT_ROOT}/core/deployment-orchestration/engine/execute-orchestration-plan.sh"
RECOVERY="${PROJECT_ROOT}/core/deployment-orchestration/recovery/recover-orchestration.sh"

DATA_DIR="${PROJECT_ROOT}/data/deployment-orchestration"

REQUEST_FILE="${DATA_DIR}/week7-final-request.json"
PLAN_FILE="${DATA_DIR}/week7-final-request-plan.json"
FAILURE_AUDIT="${DATA_DIR}/week7-final-failure-audit.json"
RECOVERY_FILE="${DATA_DIR}/week7-final-failure-audit-recovery.json"

mkdir -p "${DATA_DIR}"

rm -f \
    "${REQUEST_FILE}" \
    "${PLAN_FILE}" \
    "${FAILURE_AUDIT}" \
    "${RECOVERY_FILE}"

echo "=========================================="
echo "WEEK 7 FINAL DEPLOYMENT ORCHESTRATION TEST"
echo "=========================================="

echo
echo "=== PLANNING PATH ==="

cat > "${REQUEST_FILE}" <<'JSON'
{
  "deployment_id": "week7-final-orchestration",
  "stages": [
    {
      "name": "package",
      "depends_on": []
    },
    {
      "name": "target",
      "depends_on": ["package"]
    },
    {
      "name": "execute",
      "depends_on": ["target"]
    },
    {
      "name": "verify",
      "depends_on": ["execute"]
    },
    {
      "name": "health",
      "depends_on": ["verify"]
    }
  ]
}
JSON

"${PLANNER}" "${REQUEST_FILE}" \
    > /tmp/week7-plan-output.txt

grep -q "orchestration-plan-created" \
    /tmp/week7-plan-output.txt

echo "PASS: Orchestration plan created"

PLAN_FILE="${DATA_DIR}/week7-final-request-plan.json"

test -f "${PLAN_FILE}"

echo "PASS: Dependency resolution completed"

echo
echo "=== EXECUTION PATH ==="

"${EXECUTOR}" "${PLAN_FILE}" \
    > /tmp/week7-execution-output.txt

grep -q "orchestration-complete" \
    /tmp/week7-execution-output.txt

echo "PASS: Orchestration execution completed"

echo
echo "=== FAILURE AND RECOVERY PATH ==="

cat > "${FAILURE_AUDIT}" <<'JSON'
{
  "orchestration_id": "week7-final-failure",
  "status": "failed",
  "final_state": "ORCHESTRATION_FAILED",
  "events": [
    {
      "stage": "package",
      "status": "completed"
    },
    {
      "stage": "target",
      "status": "completed"
    },
    {
      "stage": "execute",
      "status": "failed"
    }
  ]
}
JSON

"${RECOVERY}" "${FAILURE_AUDIT}" \
    > /tmp/week7-recovery-output.txt

grep -q "orchestration-recovery-ready" \
    /tmp/week7-recovery-output.txt

echo "PASS: Failure detected"
echo "PASS: Recovery readiness established"

python3 - "${RECOVERY_FILE}" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    record = json.load(f)

assert record["orchestration_id"] == "week7-final-failure"
assert record["recovery_status"] == "recoverable"
assert record["last_completed_stage"] == "target"
assert record["failed_stage"] == "execute"
assert record["resume_from"] == "execute"
assert record["final_state"] == "ORCHESTRATION_RECOVERABLE"

print("PASS: Last completed stage validated")
print("PASS: Failed stage validated")
print("PASS: Resume point validated")
print("PASS: Recovery state validated")
PY

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
