#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

RESUME_ENGINE="${PROJECT_ROOT}/core/deployment-orchestration/resume/resume-orchestration.sh"


RECOVERY_FILE="${PROJECT_ROOT}/data/deployment-audit/week8-day3-resume-test-v1.0.0-staging-orchestration-recovery.json"


echo "=== ORCHESTRATION RESUME TEST ==="RECOVERY_FILE="${PROJECT_ROOT}/data/deployment-audit/week8-day3-resume-test-v1.0.0-staging-orchestration-recovery.json"


OUTPUT="$(
"${RESUME_ENGINE}" \
"${RECOVERY_FILE}"
)"


echo "${OUTPUT}"


echo "${OUTPUT}" | grep -q "orchestration-resume-ready"

echo "PASS: Resume readiness"


echo "${OUTPUT}" | grep -q "resume_status=ready"

echo "PASS: Resume status"


echo "${OUTPUT}" | grep -q "resume_from=ROLLED_BACK"

echo "PASS: Resume point identified"


echo

echo "PASS: Orchestration Resume Engine"
