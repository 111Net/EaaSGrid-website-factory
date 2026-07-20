#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "=== WEEK 4 RUNTIME INTEGRATION TESTS ==="

test -x "${PROJECT_ROOT}/core/runtime/engine/runtime-loader.sh"
echo "PASS: Runtime loader"

test -x "${PROJECT_ROOT}/core/static-runtime/engine/load-static-website.sh"
echo "PASS: Static runtime"

test -x "${PROJECT_ROOT}/core/preview-manager/engine/register-preview.sh"
echo "PASS: Preview manager"

test -x "${PROJECT_ROOT}/core/environment-manager/engine/create-environment.sh"
echo "PASS: Environment manager"

test -x "${PROJECT_ROOT}/core/health-monitoring/engine/check-runtime-health.sh"
echo "PASS: Health monitoring"

echo
echo "PASS: Runtime integration dependencies"

echo
echo "=== RUNTIME INTEGRATION ENGINE ==="

"${PROJECT_ROOT}/core/runtime-integration/engine/integrate-runtime.sh" \
    | grep -q "runtime-integration-ready"

echo "PASS: Runtime integration engine"

echo
echo "=== HEALTH INTEGRATION ==="

health="$(
    "${PROJECT_ROOT}/core/health-monitoring/engine/check-runtime-health.sh"
)"

[[ "${health}" == "healthy" ]]

echo "PASS: Runtime health: ${health}"

echo
echo "=== REGISTRY VALIDATION ==="

python3 - <<PY
import json
from pathlib import Path

files = [
    Path("${PROJECT_ROOT}/data/environment-manager/environment-registry.json"),
    Path("${PROJECT_ROOT}/data/preview-manager/preview-registry.json"),
    Path("${PROJECT_ROOT}/schemas/runtime-integration/runtime-integration.schema.json")
]

for file in files:
    json.loads(file.read_text())
    print(f"PASS: {file}")

print(f"PASS: {len(files)} JSON files validated")
PY

echo
echo "PASS: Runtime Integration"
