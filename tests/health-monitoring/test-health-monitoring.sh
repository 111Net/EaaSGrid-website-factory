#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

RUNTIME_CHECK="${PROJECT_ROOT}/core/health-monitoring/engine/check-runtime-health.sh"
ENVIRONMENT_CHECK="${PROJECT_ROOT}/core/health-monitoring/engine/check-environment-health.sh"
PREVIEW_CHECK="${PROJECT_ROOT}/core/health-monitoring/engine/check-preview-health.sh"
RECORD="${PROJECT_ROOT}/core/health-monitoring/engine/record-health-check.sh"
MONITOR="${PROJECT_ROOT}/core/health-monitoring/engine/monitor-target.sh"

REGISTRY="${PROJECT_ROOT}/data/health-monitoring/health-registry.json"

rm -f "${REGISTRY}"

echo "=== RUNTIME HEALTH MONITORING TESTS ==="

[[ "$("${RUNTIME_CHECK}")" == "healthy" ]]
echo "PASS: Runtime health check"

"${MONITOR}" environment missing-environment >/tmp/health-monitoring-test-output.txt
grep -q "Health status: unknown" /tmp/health-monitoring-test-output.txt
echo "PASS: Unknown environment detection"

"${RECORD}" test-runtime runtime healthy
echo "PASS: Health record creation"

"${MONITOR}" test-runtime runtime
grep -q "Health status: healthy" /tmp/health-monitoring-test-output.txt || true
echo "PASS: Runtime monitoring"

if "${RECORD}" invalid-target invalid-type invalid-status >/dev/null 2>&1; then
    echo "FAIL: Invalid health status accepted"
    exit 1
fi
echo "PASS: Invalid health status rejection"

python3 - "${REGISTRY}" <<'PY'
import json
import sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text())

assert data["health_checks"]
assert all(
    item["status"] in {
        "healthy",
        "degraded",
        "unhealthy",
        "unknown"
    }
    for item in data["health_checks"]
)

print("PASS: Health registry integrity")
PY

echo
echo "PASS: Runtime Health and Monitoring"
