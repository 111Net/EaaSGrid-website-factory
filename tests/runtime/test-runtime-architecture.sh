#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "=== WEBSITE RUNTIME ARCHITECTURE TESTS ==="

test -x "${PROJECT_ROOT}/core/runtime/engine/runtime-context.sh"
echo "PASS: Runtime context"

test -x "${PROJECT_ROOT}/core/runtime/engine/validate-runtime.sh"
echo "PASS: Runtime validation"

test -x "${PROJECT_ROOT}/core/runtime/engine/runtime-loader.sh"
echo "PASS: Runtime loader"

test -f "${PROJECT_ROOT}/core/runtime/runtime-contract.json"
echo "PASS: Runtime contract"

"${PROJECT_ROOT}/core/runtime/engine/runtime-loader.sh" >/tmp/eaasgrid-runtime-test.log

grep -q "Website runtime loaded successfully" \
    /tmp/eaasgrid-runtime-test.log

echo "PASS: Runtime loading"

echo
echo "PASS: Website Runtime Architecture"
