#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

ADAPTER="${PROJECT_ROOT}/core/deployment-orchestration/adapters/deployment-lifecycle-adapter.sh"

WEBSITE_ID="week8-day1-adapter-test"
ENVIRONMENT="staging"
VERSION="v1.0.0"

AUDIT_FILE="${PROJECT_ROOT}/data/deployment-audit/${WEBSITE_ID}-${VERSION}-${ENVIRONMENT}.json"

rm -f "${AUDIT_FILE}"

echo "=== DEPLOYMENT LIFECYCLE ADAPTER TEST ==="

OUTPUT="$(
    "${ADAPTER}" \
        "${WEBSITE_ID}" \
        "${ENVIRONMENT}" \
        "${VERSION}"
)"

printf '%s\n' "${OUTPUT}" \
    | grep -q "deployment-lifecycle-adapter-complete"

echo "PASS: Lifecycle adapter completed"

printf '%s\n' "${OUTPUT}" \
    | grep -q "lifecycle_status=complete"

echo "PASS: Lifecycle completion propagated"

printf '%s\n' "${OUTPUT}" \
    | grep -q "final_state=COMPLETED"

echo "PASS: Final state propagated"

test -f "${AUDIT_FILE}"

echo "PASS: Lifecycle audit record exists"

python3 - "${AUDIT_FILE}" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    record = json.load(f)

assert record["lifecycle_status"] == "complete"
assert record["final_state"] == "COMPLETED"
assert len(record["transitions"]) >= 6

print("PASS: Lifecycle audit validated")
print("PASS: Lifecycle transition history validated")
PY

echo
echo "PASS: Deployment Lifecycle Adapter"
