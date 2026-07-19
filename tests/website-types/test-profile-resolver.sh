#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RESOLVER="${PROJECT_ROOT}/core/website-types/resolver/profile-resolver.sh"
BLUEPRINT="${PROJECT_ROOT}/core/website-types/resolver/blueprint-resolver.sh"

echo "=== WEBSITE TYPE PROFILE RESOLVER TESTS ==="

declare -A TYPES=(
    [auto-mechanic]="auto-mechanic"
    [systems-integrator]="systems-integrator"
    [personal-website]="personal"
    [trades-services]="trades-services"
)

for type in "${!TYPES[@]}"
do
    resolved="$("${RESOLVER}" "${type}")"

    expected="${PROJECT_ROOT}/profiles/${TYPES[$type]}"

    [[ "${resolved}" == "${expected}" ]] || {
        echo "FAIL: ${type} resolved incorrectly"
        echo "Expected: ${expected}"
        echo "Actual: ${resolved}"
        exit 1
    }

    echo "PASS: ${type} profile resolution"

    "${BLUEPRINT}" "${type}" >/dev/null

    echo "PASS: ${type} blueprint resolution"
done

if "${RESOLVER}" "unsupported-type" >/dev/null 2>&1; then
    echo "FAIL: Unsupported type was accepted"
    exit 1
fi

echo "PASS: Unsupported website type rejection"

echo
echo "PASS: Website Type Profile Resolver"
