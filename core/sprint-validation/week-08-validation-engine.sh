#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "=========================================="
echo "WEEK 8 MASTER AUTOMATED VALIDATION GATE"
echo "=========================================="

FAILED=0


run_test() {

    NAME="$1"
    SCRIPT="$2"

    echo
    echo "=========================================="
    echo "JOB: ${NAME}"
    echo "=========================================="

    if bash "${PROJECT_ROOT}/${SCRIPT}"
    then
        echo "PASS: ${NAME}"
    else
        echo "FAIL: ${NAME}"
        FAILED=1
    fi
}


run_test \
"Deployment Orchestration Planning" \
"tests/deployment-orchestration/test-deployment-orchestration-plan.sh"


run_test \
"Deployment Execution and Failure Handling" \
"tests/deployment-orchestration/test-deployment-orchestration-execution.sh"


run_test \
"Rollback and Recovery Integration" \
"tests/deployment-orchestration/test-deployment-orchestration-recovery.sh"


run_test \
"Resume Execution Engine" \
"tests/deployment-orchestration/test-orchestration-resume.sh"


run_test \
"Hardening Controls" \
"tests/sprint-gates/week-08-day-05-hardening-test.sh"


echo

if [[ ${FAILED} -eq 0 ]]
then

echo "=========================================="
echo "WEEK 8 FINAL STATUS: GREEN"
echo "=========================================="

echo "weekly_gate=PASS"

exit 0

else

echo "=========================================="
echo "WEEK 8 FINAL STATUS: RED"
echo "=========================================="

echo "weekly_gate=FAIL"

exit 1

fi
