#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLIENT_ID="day07-build-test"
CLIENT_ROOT="${PROJECT_ROOT}/clients/${CLIENT_ID}"

rm -rf "${CLIENT_ROOT}"

mkdir -p \
    "${CLIENT_ROOT}/configuration" \
    "${CLIENT_ROOT}/generated"

cat > "${CLIENT_ROOT}/client.json" <<JSON
{
  "client_id": "${CLIENT_ID}",
  "name": "Day 7 Build Test"
}
JSON

"${PROJECT_ROOT}/core/build/engine/build-website.sh" "${CLIENT_ID}" >/dev/null

test -f "${CLIENT_ROOT}/build/build-manifest.json" \
    && echo "PASS: Build manifest generated"

test -d "${CLIENT_ROOT}/build" \
    && echo "PASS: Build directory created"

python3 - "${CLIENT_ROOT}/build/build-manifest.json" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    data = json.load(f)

assert data["status"] == "built"
assert len(data["pipeline"]) >= 7

print("PASS: Build pipeline manifest validated")
PY

rm -rf "${CLIENT_ROOT}"

echo
echo "PASS: Website Build Pipeline"
