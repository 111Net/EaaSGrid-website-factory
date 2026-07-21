#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

echo "=========================================="
echo "WEEK 8 DAY 5 HARDENING GATE"
echo "=========================================="


echo
echo "1. IDEMPOTENCY"

bash \
"${PROJECT_ROOT}/core/deployment-orchestration/hardening/idempotency-check.sh" \
"week8-day3-resume-test-v1.0.0-staging"


echo
echo "2. STATE INTEGRITY"

bash \
"${PROJECT_ROOT}/core/deployment-orchestration/hardening/state-integrity-check.sh"


echo
echo "3. RECOVERY SAFETY"

bash \
"${PROJECT_ROOT}/core/deployment-orchestration/hardening/recovery-safety-check.sh" \
"${PROJECT_ROOT}/data/deployment-audit/week8-day3-resume-test-v1.0.0-staging-orchestration-recovery.json"


echo
echo "=========================================="
echo "WEEK 8 DAY 5 STATUS: GREEN"
echo "=========================================="

echo "hardening_gate=PASS"

