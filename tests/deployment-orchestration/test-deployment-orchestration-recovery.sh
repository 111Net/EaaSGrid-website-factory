#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

RECOVERY_ENGINE="${PROJECT_ROOT}/core/deployment-orchestration/recovery/recover-orchestration.sh"

AUDIT_FILE="${PROJECT_ROOT}/data/deployment-orchestration/test-failed-orchestration.json"
RECOVERY_FILE="${PROJECT_ROOT}/data/deployment-orchestration/test-failed-orchestration-recovery.json"

mkdir -p "$(dirname "${AUDIT_FILE}")"

cat > "${AUDIT_FILE}" <<'JSON'
{
  "orchestration_id": "test-failed-orchestration",
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

echo "=== ORCHESTRATION RECOVERY TESTS ==="

"${RECOVERY_ENGINE}" "${AUDIT_FILE}" \
    | grep -q "orchestration-recovery-ready"

echo "PASS: Recovery readiness"

python3 - "${RECOVERY_FILE}" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    record = json.load(f)

assert record["orchestration_id"] == "test-failed-orchestration"
assert record["recovery_status"] == "recoverable"
assert record["last_completed_stage"] == "target"
assert record["failed_stage"] == "execute"
assert record["resume_from"] == "execute"
assert record["final_state"] == "ORCHESTRATION_RECOVERABLE"

print("PASS: Last completed stage identified")
print("PASS: Failed stage identified")
print("PASS: Resume point identified")
print("PASS: Recovery state recorded")
PY

rm -f "${AUDIT_FILE}" "${RECOVERY_FILE}"

echo
echo "PASS: Deployment Orchestration Recovery"
