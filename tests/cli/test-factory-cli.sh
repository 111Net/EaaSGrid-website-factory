#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLI="${PROJECT_ROOT}/core/cli/factory.sh"
TEST_CLIENT="${PROJECT_ROOT}/clients/_day01-test-client"

rm -rf "${TEST_CLIENT}"

echo "PASS: CLI exists"
[[ -x "${CLI}" ]]

STATUS_OUTPUT="$("${CLI}" status)"
echo "${STATUS_OUTPUT}" | grep -q "EaaSGrid Website Factory"
echo "PASS: CLI status command"

"${CLI}" create \
    --name "Day 01 Test Client" \
    --type "auto-mechanic" \
    --theme "professional" \
    --structure "hybrid" \
    > /tmp/day01-create-output.txt

[[ -d "${PROJECT_ROOT}/clients/day-01-test-client" ]]
echo "PASS: Client project generated"

[[ -f "${PROJECT_ROOT}/clients/day-01-test-client/client.json" ]]
[[ -f "${PROJECT_ROOT}/clients/day-01-test-client/website.json" ]]
echo "PASS: Client configuration generated"

grep -q '"client_name": "Day 01 Test Client"' \
    "${PROJECT_ROOT}/clients/day-01-test-client/client.json"

grep -q '"type": "auto-mechanic"' \
    "${PROJECT_ROOT}/clients/day-01-test-client/website.json"

echo "PASS: Client identity configuration"
echo "PASS: Website configuration"

if "${CLI}" create \
    --name "Day 01 Test Client" \
    --type "auto-mechanic" \
    >/dev/null 2>&1; then
    echo "FAIL: Duplicate client protection"
    exit 1
fi

echo "PASS: Duplicate client protection"

rm -rf "${PROJECT_ROOT}/clients/day-01-test-client"
rm -f /tmp/day01-create-output.txt

echo "PASS: Test cleanup"
