#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

AUDIT_ENGINE="${PROJECT_ROOT}/core/deployment-audit/engine/record-deployment-audit.sh"

AUDIT_FILE="${PROJECT_ROOT}/data/deployment-audit/test-audit.json"

rm -f "${AUDIT_FILE}"

TRANSITIONS='[
  {"from":"CREATED","to":"PACKAGED"},
  {"from":"PACKAGED","to":"TARGET_RESOLVED"},
  {"from":"TARGET_RESOLVED","to":"EXECUTED"},
  {"from":"EXECUTED","to":"VERIFIED"},
  {"from":"VERIFIED","to":"HEALTH_CHECKED"},
  {"from":"HEALTH_CHECKED","to":"COMPLETED"}
]'

echo "=== DEPLOYMENT AUDIT TESTS ==="

"${AUDIT_ENGINE}" \
    "${AUDIT_FILE}" \
    "test-audit-deployment" \
    "test-audit-website" \
    "staging" \
    "v1.0.0" \
    "complete" \
    "COMPLETED" \
    "${TRANSITIONS}" \
    | grep -q "deployment-audit-recorded"

echo "PASS: Audit record creation"

python3 - "${AUDIT_FILE}" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    record = json.load(f)

assert record["deployment_id"] == "test-audit-deployment"
assert record["website_id"] == "test-audit-website"
assert record["lifecycle_status"] == "complete"
assert record["final_state"] == "COMPLETED"
assert len(record["transitions"]) == 6

print("PASS: Audit record structure")
print("PASS: Transition history")
PY

rm -f "${AUDIT_FILE}"

echo
echo "PASS: Deployment Lifecycle Audit Recorder"
