#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLIENT_ID="week3-day01-render-test"
CLIENT_ROOT="${PROJECT_ROOT}/clients/${CLIENT_ID}"

rm -rf "${CLIENT_ROOT}"

mkdir -p \
    "${CLIENT_ROOT}/build" \
    "${CLIENT_ROOT}/generated"

cat > "${CLIENT_ROOT}/client.json" <<JSON
{
  "client_id": "${CLIENT_ID}",
  "name": "Week 3 Rendering Test"
}
JSON

"${PROJECT_ROOT}/core/rendering/engine/render-website.sh" "${CLIENT_ID}" >/dev/null

test -f "${CLIENT_ROOT}/generated/rendered/rendering-manifest.json" \
    && echo "PASS: Rendering manifest generated"

test -x "${PROJECT_ROOT}/core/rendering/engine/render-page.sh" \
    && echo "PASS: Page renderer"

test -x "${PROJECT_ROOT}/core/rendering/engine/render-section.sh" \
    && echo "PASS: Section renderer"

test -x "${PROJECT_ROOT}/core/rendering/engine/render-component.sh" \
    && echo "PASS: Component renderer"

"${PROJECT_ROOT}/core/rendering/engine/render-page.sh" "home" \
    | grep -q '<!DOCTYPE html>' \
    && echo "PASS: Page rendering contract"

"${PROJECT_ROOT}/core/rendering/engine/render-section.sh" "hero" \
    | grep -q 'data-section="hero"' \
    && echo "PASS: Section rendering contract"

"${PROJECT_ROOT}/core/rendering/engine/render-component.sh" "button" \
    | grep -q 'data-component="button"' \
    && echo "PASS: Component rendering contract"

python3 - "${CLIENT_ROOT}/generated/rendered/rendering-manifest.json" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    data = json.load(f)

assert data["renderer"] == "generic"
assert data["status"] == "initialized"
assert len(data["layers"]) == 5

print("PASS: Rendering manifest validated")
PY

rm -rf "${CLIENT_ROOT}"

echo
echo "PASS: Rendering Architecture"
