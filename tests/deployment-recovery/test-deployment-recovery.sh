#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

RECOVERY_ENGINE="${PROJECT_ROOT}/core/deployment-recovery/engine/recover-deployment-lifecycle.sh"

AUDIT_DIR="${PROJECT_ROOT}/data/deployment-audit"
DEPLOYMENT_DIR="${PROJECT_ROOT}/data/deployment-executor/deployments/test-recovery-deployment-v1.0.0-staging"

AUDIT_FILE="${AUDIT_DIR}/test-recovery-audit.json"

rm -rf "${DEPLOYMENT_DIR}"
mkdir -p "${DEPLOYMENT_DIR}"

cat > "${DEPLOYMENT_DIR}/deployment-record.json" <<'JSON'
{
  "deployment_id": "test-recovery-deployment-v1.0.0-staging",
  "deployment_status": "deployed"
}
JSON

cat > "${AUDIT_FILE}" <<'JSON'
{
  "deployment_id": "test-recovery-deployment-v1.0.0-staging",
  "website_id": "test-recovery-website",
  "environment": "staging",
  "version": "v1.0.0",
  "lifecycle_status": "complete",
  "final_state": "COMPLETED",
  "transitions": [
    {
      "from": "CREATED",
      "to": "PACKAGED"
    },
    {
      "from": "PACKAGED",
      "to": "TARGET_RESOLVED"
    },
    {
      "from": "TARGET_RESOLVED",
      "to": "EXECUTED"
    },
    {
      "from": "EXECUTED",
      "to": "VERIFIED"
    },
    {
      "from": "VERIFIED",
      "to": "HEALTH_CHECKED"
    },
    {
      "from": "HEALTH_CHECKED",
      "to": "COMPLETED"
    }
  ]
}
JSON

echo "=== DEPLOYMENT RECOVERY TESTS ==="

"${RECOVERY_ENGINE}" \
    "${AUDIT_FILE}" \
    "${DEPLOYMENT_DIR}" \
    | grep -q "deployment-lifecycle-recovered"

echo "PASS: Lifecycle recovery"

python3 - "${DEPLOYMENT_DIR}/deployment-record.json" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    record = json.load(f)

assert record["recovery_status"] == "RECOVERED"
assert record["recovered_from_state"] == "COMPLETED"

print("PASS: Recovery state recorded")
print("PASS: Completed lifecycle recovery")
PY

rm -rf \
    "${AUDIT_FILE}" \
    "${DEPLOYMENT_DIR}"

echo
echo "PASS: Deployment Lifecycle Recovery Engine"
