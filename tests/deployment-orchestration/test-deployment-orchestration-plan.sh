#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

ENGINE="${PROJECT_ROOT}/core/deployment-orchestration/engine/create-orchestration-plan.sh"
TEST_DIR="${PROJECT_ROOT}/data/deployment-orchestration-test"

rm -rf "${TEST_DIR}"
mkdir -p "${TEST_DIR}"

SUCCESS_REQUEST="${TEST_DIR}/success-request.json"

cat > "${SUCCESS_REQUEST}" <<'JSON'
{
  "deployment_id": "orchestration-test-v1.0.0",
  "stages": [
    {
      "name": "package",
      "depends_on": []
    },
    {
      "name": "target",
      "depends_on": [
        "package"
      ]
    },
    {
      "name": "execute",
      "depends_on": [
        "target"
      ]
    },
    {
      "name": "verify",
      "depends_on": [
        "execute"
      ]
    },
    {
      "name": "health",
      "depends_on": [
        "verify"
      ]
    }
  ]
}
JSON

echo "=== DEPLOYMENT ORCHESTRATION PLAN TESTS ==="

"${ENGINE}" "${SUCCESS_REQUEST}" \
    | grep -q "orchestration-plan-created"

echo "PASS: Valid orchestration plan"

python3 - "${TEST_DIR}/success-request-plan.json" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    plan = json.load(f)

assert plan["plan_status"] == "valid"
assert plan["stage_count"] == 5

assert plan["execution_order"] == [
    "package",
    "target",
    "execute",
    "verify",
    "health"
]

print("PASS: Dependency resolution")
print("PASS: Deterministic execution order")
PY

CIRCULAR_REQUEST="${TEST_DIR}/circular-request.json"

cat > "${CIRCULAR_REQUEST}" <<'JSON'
{
  "deployment_id": "circular-test-v1.0.0",
  "stages": [
    {
      "name": "package",
      "depends_on": [
        "verify"
      ]
    },
    {
      "name": "verify",
      "depends_on": [
        "package"
      ]
    }
  ]
}
JSON

if "${ENGINE}" "${CIRCULAR_REQUEST}" \
    > "${TEST_DIR}/circular-output.txt" 2>&1; then
    echo "FAIL: Circular dependency was accepted"
    exit 1
fi

grep -q "circular dependency detected" \
    "${TEST_DIR}/circular-output.txt"

echo "PASS: Circular dependency rejected"

rm -rf "${TEST_DIR}"

echo
echo "PASS: Deployment Orchestration Planning"
