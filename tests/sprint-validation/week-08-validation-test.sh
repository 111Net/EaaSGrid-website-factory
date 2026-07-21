#!/usr/bin/env bash

set -Eeuo pipefail


PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

ENGINE="${PROJECT_ROOT}/core/sprint-validation/week-08-validation-engine.sh"


echo "=========================================="
echo "WEEK 8 MASTER VALIDATION TEST"
echo "=========================================="


OUTPUT="$("${ENGINE}")"


echo "${OUTPUT}"


echo "${OUTPUT}" | grep -q "weekly_gate=PASS"


echo
echo "PASS: WEEK 8 MASTER AUTOMATED GATE"
