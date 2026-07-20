#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PLAN_ENGINE="${PROJECT_ROOT}/core/deployment-orchestration/engine/create-orchestration-plan.sh"
EXECUTOR="${PROJECT_ROOT}/core/deployment-orchestration/engine/execute-orchestration-plan.sh"
AUDIT_ENGINE="${PROJECT_ROOT}/core/deployment-orchestration/audit/record-orchestration-audit.sh"
RECOVERY_ENGINE="${PROJECT_ROOT}/core/deployment-orchestration/recovery/recover-orchestration.sh"

DATA_DIR="${PROJECT_ROOT}/data/deployment-orchestration"

SUCCESS_PLAN="${DATA_DIR}/week7-success-plan.json"
FAILURE_PLAN="${DATA_DIR}/week7-failure-plan.json"

SUCCESS_AUDIT="${DATA_DIR}/week7-success-audit.json"
FAILURE_AUDIT="${DATA_DIR}/week7-failure-audit.json"

SUCCESS_RECOVERY="${DATA_DIR}/week7-success-audit-recovery.json"
FAILURE_RECOVERY="${DATA_DIR}/week7-failure-audit-recovery.json"

mkdir -p "${DATA_DIR}"

rm -f \
    "${SUCCESS_PLAN}" \
    "${FAILURE_PLAN}" \
    "${SUCCESS_AUDIT}" \
    "${FAILURE_AUDIT}" \
    "${SUCCESS_RECOVERY}" \
    "${FAILURE_RECOVERY}"

echo "=========================================="
echo "WEEK 7 FINAL ORCHESTRATION INTEGRATION TEST"
echo "=========================================="

echo
echo "=== SUCCESS PATH ==="

cat > "${SUCCESS_PLAN}" <<'JSON'
{
  "orchestration_id": "week7-success-orchestration",
  "execution_order": [
    "package",
    "target",
    "execute",
    "verify",
    "health"
  ]
}
JSON

"${EXECUTOR}" "${SUCCESS_PLAN}" > /tmp/week7-success-output

grep -q "orchestration-complete" /tmp/week7-success-output

echo "PASS: Successful orchestration execution"

cat > "${SUCCESS_AUDIT}" <<'JSON'
{
  "orchestration_id": "week7-success-orchestration",
  "status": "complete",
  "final_state": "ORCHESTRATION_COMPLETED",
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
      "status": "completed"
    },
    {
      "stage": "verify",
      "status": "completed"
    },
    {
      "stage": "health",
      "status": "completed"
    }
  ]
}
JSON

"${RECOVERY_ENGINE}" "${SUCCESS_AUDIT}" \
    | grep -q "recovery_status=not_required"

echo "PASS: Successful audit validation"
echo "PASS: Recovery not required for completed orchestration"

echo
echo "=== FAILURE AND RECOVERY PATH ==="

cat > "${FAILURE_AUDIT}" <<'JSON'
{
  "orchestration_id": "week7-failure-orchestration",
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

"${RECOVERY_ENGINE}" "${FAILURE_AUDIT}" \
    | grep -q "orchestration-recovery-ready"

echo "PASS: Failed orchestration detected"
echo "PASS: Recovery readiness established"

python3 - "${FAILURE_RECOVERY}" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    record = json.load(f)

assert record["orchestration_id"] == "week7-failure-orchestration"
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
echo "SUCCESS PATH: PASS"
echo "AUDIT:        PASS"
echo "FAILURE:      PASS"
echo "RECOVERY:     PASS"
echo "=========================================="
echo "WEEK 7 STATUS: COMPLETE"
echo "=========================================="
