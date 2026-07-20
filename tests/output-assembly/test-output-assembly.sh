#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${PROJECT_ROOT}"

ASSEMBLER="core/output-assembly/engine/assemble-website-output.sh"
TEST_ROOT="/tmp/eaasgrid-output-assembly-test"

rm -rf "${TEST_ROOT}"
mkdir -p "${TEST_ROOT}/source"

echo "=== FINAL WEBSITE OUTPUT ASSEMBLY TESTS ==="

test -x "${ASSEMBLER}"
echo "PASS: Output assembly engine"

for profile in \
    auto-mechanic \
    systems-integrator \
    personal \
    trades-services
do
    test -d "profiles/${profile}"
    echo "PASS: ${profile} profile available"
done

"${ASSEMBLER}" \
    "${TEST_ROOT}/source" \
    "${TEST_ROOT}/output" >/dev/null

test -f "${TEST_ROOT}/output/output-manifest.json"
echo "PASS: Output manifest"

for directory in \
    pages \
    sections \
    components \
    assets \
    styles \
    scripts \
    config
do
    test -d "${TEST_ROOT}/output/${directory}"
    echo "PASS: ${directory} output"
done

python3 - "${TEST_ROOT}/output/output-manifest.json" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    data = json.load(f)

assert data["output_type"] == "website"
assert data["status"] == "assembled"
assert len(data["directories"]) >= 7

print("PASS: Output manifest structure")
PY

rm -rf "${TEST_ROOT}"

echo
echo "PASS: Final Website Output Assembly"
