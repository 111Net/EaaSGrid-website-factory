#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

echo "=========================================="
echo "WEEK 8 DAY 4 RESUME INTEGRATION GATE"
echo "=========================================="

TESTS=(
"tests/deployment-orchestration/test-deployment-orchestration-plan.sh"
"tests/deployment-orchestration/test-deployment-orchestration-execution.sh"
"tests/deployment-orchestration/test-deployment-orchestration-recovery.sh"
"tests/deployment-orchestration/test-orchestration-resume.sh"
)

for TEST in "${TESTS[@]}"
do

    echo
    echo "RUNNING: ${TEST}"

    if bash "${PROJECT_ROOT}/${TEST}"
    then
        echo "PASS: ${TEST}"
    else
        echo "FAIL: ${TEST}"
        exit 1
    fi

done


echo
echo "=========================================="
echo "WEEK 8 DAY 4 STATUS: GREEN"
echo "=========================================="

echo "resume_integration=complete"
echo "gate_status=PASS"
