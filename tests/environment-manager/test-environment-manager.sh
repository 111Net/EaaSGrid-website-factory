#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

CREATE="${PROJECT_ROOT}/core/environment-manager/engine/create-environment.sh"
START="${PROJECT_ROOT}/core/environment-manager/engine/start-environment.sh"
STOP="${PROJECT_ROOT}/core/environment-manager/engine/stop-environment.sh"
STATUS="${PROJECT_ROOT}/core/environment-manager/engine/environment-status.sh"
DESTROY="${PROJECT_ROOT}/core/environment-manager/engine/destroy-environment.sh"

REGISTRY="${PROJECT_ROOT}/data/environment-manager/environment-registry.json"

rm -f "${REGISTRY}"

echo "=== WEBSITE ENVIRONMENT MANAGER TESTS ==="

"${CREATE}" env-a client-a preview-a
[[ "$("${STATUS}" env-a)" == "created" ]]
echo "PASS: Environment creation"

"${START}" env-a
[[ "$("${STATUS}" env-a)" == "running" ]]
echo "PASS: Environment start"

"${STOP}" env-a
[[ "$("${STATUS}" env-a)" == "stopped" ]]
echo "PASS: Environment stop"

"${START}" env-a
[[ "$("${STATUS}" env-a)" == "running" ]]
echo "PASS: Environment restart lifecycle"

"${STOP}" env-a

"${CREATE}" env-b client-b preview-b
echo "PASS: Multiple environment support"

if "${CREATE}" env-a client-a preview-a >/dev/null 2>&1; then
    echo "FAIL: Duplicate environment accepted"
    exit 1
fi
echo "PASS: Duplicate environment rejection"

if "${STATUS}" missing-environment >/dev/null 2>&1; then
    echo "FAIL: Invalid environment accepted"
    exit 1
fi
echo "PASS: Invalid environment rejection"

"${DESTROY}" env-a
[[ "$("${STATUS}" env-a)" == "destroyed" ]]
echo "PASS: Environment destruction"

echo
echo "PASS: Website Environment Manager"
