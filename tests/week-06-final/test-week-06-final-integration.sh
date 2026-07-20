#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

CONTROLLER="${PROJECT_ROOT}/core/deployment-controller/engine/deployment-controller.sh"
RECOVERY="${PROJECT_ROOT}/core/deployment-recovery/engine/recover-deployment-lifecycle.sh"

AUDIT_DIR="${PROJECT_ROOT}/data/deployment-audit"

SUCCESS_ID="week6-success-website"
FAILURE_ID="week6-failure-website"
ENVIRONMENT="staging"
VERSION="v1.0.0"

SUCCESS_PACKAGE="${PROJECT_ROOT}/data/deployment-package/packages/${SUCCESS_ID}/${VERSION}"
SUCCESS_DEPLOYMENT="${PROJECT_ROOT}/data/deployment-executor/deployments/${SUCCESS_ID}-${VERSION}-${ENVIRONMENT}"
SUCCESS_AUDIT="${AUDIT_DIR}/${SUCCESS_ID}-${VERSION}-${ENVIRONMENT}.json"

FAILURE_PACKAGE="${PROJECT_ROOT}/data/deployment-package/packages/${FAILURE_ID}/${VERSION}"
FAILURE_DEPLOYMENT="${PROJECT_ROOT}/data/deployment-executor/deployments/${FAILURE_ID}-${VERSION}-${ENVIRONMENT}"
FAILURE_AUDIT="${AUDIT_DIR}/${FAILURE_ID}-${VERSION}-${ENVIRONMENT}.json"

rm -rf \
    "${SUCCESS_PACKAGE%/${VERSION}}" \
    "${SUCCESS_DEPLOYMENT}" \
    "${SUCCESS_AUDIT}" \
    "${FAILURE_PACKAGE%/${VERSION}}" \
    "${FAILURE_DEPLOYMENT}" \
    "${FAILURE_AUDIT}"

echo "=========================================="
echo "WEEK 6 FINAL DEPLOYMENT LIFECYCLE TEST"
echo "=========================================="

echo
echo "=== SUCCESS PATH ==="

"${CONTROLLER}" \
    "${SUCCESS_ID}" \
    "${ENVIRONMENT}" \
    "${VERSION}" \
    | tee /tmp/week6-success-output.txt

grep -q "lifecycle_status=complete" /tmp/week6-success-output.txt
grep -q "final_state=COMPLETED" /tmp/week6-success-output.txt

echo "PASS: Successful controller lifecycle"

if [[ ! -f "${SUCCESS_AUDIT}" ]]; then
    echo "FAIL: Success audit record missing"
    exit 1
fi

echo "PASS: Success audit record exists"

"${RECOVERY}" \
    "${SUCCESS_AUDIT}" \
    "${SUCCESS_DEPLOYMENT}" \
    | grep -q "deployment-lifecycle-recovered"

echo "PASS: Successful lifecycle recovery"

echo
echo "=== FAILURE PATH ==="

set +e
CONTROLLER_INJECT_FAILURE=verify \
    "${CONTROLLER}" \
    "${FAILURE_ID}" \
    "${ENVIRONMENT}" \
    "${VERSION}" \
    > /tmp/week6-failure-output.txt 2>&1
FAILURE_EXIT=$?
set -e

if [[ "${FAILURE_EXIT}" -eq 0 ]]; then
    echo "FAIL: Failure path unexpectedly succeeded"
    cat /tmp/week6-failure-output.txt
    exit 1
fi

grep -q "lifecycle_status=rolled_back" /tmp/week6-failure-output.txt

echo "PASS: Verification failure detected"
echo "PASS: Automatic rollback triggered"

if [[ ! -f "${FAILURE_AUDIT}" ]]; then
    echo "FAIL: Failure audit record missing"
    exit 1
fi

echo "PASS: Failure audit record exists"

"${RECOVERY}" \
    "${FAILURE_AUDIT}" \
    "${FAILURE_DEPLOYMENT}" \
    | grep -q "deployment-lifecycle-recovered"

echo "PASS: Rolled-back lifecycle recovery"

python3 - \
    "${SUCCESS_AUDIT}" \
    "${FAILURE_AUDIT}" <<'PY'
import json
import sys

success = json.loads(open(sys.argv[1]).read())
failure = json.loads(open(sys.argv[2]).read())

assert success["final_state"] == "COMPLETED"
assert success["lifecycle_status"] == "complete"
assert len(success["transitions"]) >= 6

assert failure["final_state"] == "ROLLED_BACK"
assert failure["lifecycle_status"] == "rolled_back"

print("PASS: Success final state")
print("PASS: Failure final state")
print("PASS: Transition history recorded")
PY

rm -rf \
    "${SUCCESS_PACKAGE%/${VERSION}}" \
    "${SUCCESS_DEPLOYMENT}" \
    "${SUCCESS_AUDIT}" \
    "${FAILURE_PACKAGE%/${VERSION}}" \
    "${FAILURE_DEPLOYMENT}" \
    "${FAILURE_AUDIT}"

rm -f \
    /tmp/week6-success-output.txt \
    /tmp/week6-failure-output.txt

echo
echo "=========================================="
echo "WEEK 6 FINAL INTEGRATION GATE"
echo "=========================================="
echo "SUCCESS PATH: PASS"
echo "FAILURE PATH: PASS"
echo "AUDIT:        PASS"
echo "RECOVERY:     PASS"
echo "ROLLBACK:     PASS"
echo "=========================================="
echo "WEEK 6 STATUS: COMPLETE"
echo "=========================================="
