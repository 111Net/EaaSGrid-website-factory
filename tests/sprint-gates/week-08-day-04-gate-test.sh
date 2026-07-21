#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

GATE="${PROJECT_ROOT}/core/deployment-orchestration/gates/week-08-day-04-resume-gate.sh"

echo "=========================================="
echo "WEEK 8 DAY 4 AUTOMATED GATE TEST"
echo "=========================================="


if [[ ! -x "${GATE}" ]]
then
    echo "FAIL: Gate missing"
    exit 1
fi

echo "PASS: Gate exists"


OUTPUT="$(
"${GATE}"
)"

echo "${OUTPUT}"


echo "${OUTPUT}" | grep -q "gate_status=PASS"

echo "PASS: Resume integration gate validated"


echo
echo "=========================================="
echo "WEEK 8 DAY 4 AUTOMATED TEST COMPLETE"
echo "=========================================="

