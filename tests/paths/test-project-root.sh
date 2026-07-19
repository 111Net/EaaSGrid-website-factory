#!/usr/bin/env bash
set -Eeuo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "${TEST_ROOT}/core/paths/project-root.sh"

if [[ "${PROJECT_ROOT}" != "${TEST_ROOT}" ]]; then
    echo "FAIL: Project root mismatch"
    echo "Expected: ${TEST_ROOT}"
    echo "Actual: ${PROJECT_ROOT}"
    exit 1
fi

echo "PASS: Dynamic project root resolver"
