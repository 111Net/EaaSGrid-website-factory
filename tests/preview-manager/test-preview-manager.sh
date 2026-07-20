#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

REGISTER="${PROJECT_ROOT}/core/preview-manager/engine/register-preview.sh"
START="${PROJECT_ROOT}/core/preview-manager/engine/start-preview.sh"
STOP="${PROJECT_ROOT}/core/preview-manager/engine/stop-preview.sh"
STATUS="${PROJECT_ROOT}/core/preview-manager/engine/preview-status.sh"

REGISTRY="${PROJECT_ROOT}/data/preview-manager/preview-registry.json"

rm -f "${REGISTRY}"

TEST_OUTPUT="${PROJECT_ROOT}/data/preview-manager/test-output"
mkdir -p "${TEST_OUTPUT}"

echo "=== WEBSITE PREVIEW MANAGER TESTS ==="

"${REGISTER}" preview-a client-a "${TEST_OUTPUT}/client-a"
echo "PASS: Preview registration"

[[ "$("${STATUS}" preview-a)" == "registered" ]]
echo "PASS: Preview status"

"${START}" preview-a
[[ "$("${STATUS}" preview-a)" == "running" ]]
echo "PASS: Preview start"

"${REGISTER}" preview-b client-b "${TEST_OUTPUT}/client-b"
echo "PASS: Multiple preview registration"

"${STOP}" preview-a
[[ "$("${STATUS}" preview-a)" == "stopped" ]]
echo "PASS: Preview stop"

if "${REGISTER}" preview-a client-a "${TEST_OUTPUT}/client-a" >/dev/null 2>&1; then
    echo "FAIL: Duplicate preview accepted"
    exit 1
fi
echo "PASS: Duplicate preview rejection"

if "${STATUS}" missing-preview >/dev/null 2>&1; then
    echo "FAIL: Invalid preview accepted"
    exit 1
fi
echo "PASS: Invalid preview rejection"

echo
echo "PASS: Website Preview Manager"
