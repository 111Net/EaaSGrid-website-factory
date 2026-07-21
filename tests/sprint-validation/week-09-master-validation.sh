#!/usr/bin/env bash

set -Eeuo pipefail

BASE="/data/eaasgrid-website-factory"

echo "=========================================="
echo "WEEK 9 MASTER AUTOMATED VALIDATION GATE"
echo "=========================================="

cd "$BASE"

echo
echo "JOB: State Control"

core/deployment-orchestration/state-control/state-validator.sh COMPLETED
core/deployment-orchestration/state-control/transition-validator.sh EXECUTED VERIFIED

echo "PASS: State Control"

echo
echo "JOB: Policy Engine"

core/deployment-orchestration/policy-engine/policy-validator.sh staging rollback
core/deployment-orchestration/policy-engine/policy-validator.sh production deploy

echo "PASS: Policy Engine"

echo
echo "JOB: Decision Engine"

core/deployment-orchestration/decision-engine/decision-validator.sh COMPLETED true production
core/deployment-orchestration/decision-engine/decision-validator.sh EXECUTED true staging
core/deployment-orchestration/decision-engine/decision-validator.sh FAILED true staging
core/deployment-orchestration/decision-engine/decision-validator.sh ROLLED_BACK true staging

echo "PASS: Decision Engine"

echo
echo "JOB: Git Integrity"

git diff --check

echo
echo "=========================================="
echo "WEEK 9 STATUS: GREEN"
echo "=========================================="

echo "weekly_gate=PASS"
