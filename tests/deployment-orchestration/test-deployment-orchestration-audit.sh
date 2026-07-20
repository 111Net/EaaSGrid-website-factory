#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

AUDIT_ENGINE="${PROJECT_ROOT}/core/deployment-orchestration/audit/record-orchestration-audit.sh"

AUDIT_FILE="${PROJECT_ROOT}/data/deployment-orchestration/test-orchestration-audit.json"

rm -f "${AUDIT_FILE}"

EVENTS='[
  {"stage":"package","status":"completed"},
  {"stage":"target","status":"completed"},
  {"stage":"execute","status":"completed"},
  {"stage":"verify","status":"completed"},
  {"stage":"health_gate","status":"completed"}
]'

echo "=== ORCHESTRATION AUDIT TESTS ==="

"${AUDIT_ENGINE}" \
    "${AUDIT_FILE}" \
    "test-orchestration" \
    "complete" \
    "ORCHESTRATION_COMPLETED" \
    "${EVENTS}" \
    | grep -q "orchestration-audit-recorded"

echo "PASS: Audit record creation"

python3 - "${AUDIT_FILE}" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    record = json.load(f)

assert record["orchestration_id"] == "test-orchestration"
assert record["status"] == "complete"
assert record["final_state"] == "ORCHESTRATION_COMPLETED"
assert len(record["events"]) == 5

print("PASS: Audit record structure")
print("PASS: Event history")
PY

rm -f "${AUDIT_FILE}"

echo
echo "PASS: Deployment Orchestration Audit"
