#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

STATE_MACHINE="${PROJECT_ROOT}/core/deployment-state-machine/engine/deployment-state-machine.sh"

assert_valid_transition() {
    local from="$1"
    local to="$2"

    "${STATE_MACHINE}" "${from}" "${to}" \
        | grep -q "deployment-transition-valid"

    echo "PASS: ${from} -> ${to}"
}

assert_invalid_transition() {
    local from="$1"
    local to="$2"

    if "${STATE_MACHINE}" "${from}" "${to}" >/dev/null 2>&1; then
        echo "FAIL: Invalid transition accepted: ${from} -> ${to}"
        exit 1
    fi

    echo "PASS: Invalid transition rejected: ${from} -> ${to}"
}

echo "=== DEPLOYMENT STATE MACHINE TESTS ==="

assert_valid_transition CREATED PACKAGED
assert_valid_transition PACKAGED TARGET_RESOLVED
assert_valid_transition TARGET_RESOLVED EXECUTED
assert_valid_transition EXECUTED VERIFIED
assert_valid_transition VERIFIED HEALTH_CHECKED
assert_valid_transition HEALTH_CHECKED COMPLETED

assert_valid_transition EXECUTED FAILED
assert_valid_transition FAILED ROLLBACK
assert_valid_transition ROLLBACK ROLLED_BACK

assert_invalid_transition CREATED COMPLETED
assert_invalid_transition PACKAGED COMPLETED
assert_invalid_transition COMPLETED ROLLBACK
assert_invalid_transition ROLLED_BACK COMPLETED

echo
echo "PASS: Deployment Lifecycle State Machine"
