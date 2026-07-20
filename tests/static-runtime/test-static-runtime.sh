#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEST_ROOT="$(mktemp -d)"

cleanup() {
    rm -rf "${TEST_ROOT}"
}
trap cleanup EXIT

OUTPUT="${TEST_ROOT}/website"

mkdir -p \
    "${OUTPUT}/pages" \
    "${OUTPUT}/sections" \
    "${OUTPUT}/components" \
    "${OUTPUT}/assets" \
    "${OUTPUT}/styles" \
    "${OUTPUT}/scripts" \
    "${OUTPUT}/config"

cat > "${OUTPUT}/manifest.json" <<'JSON'
{
  "website": "static-runtime-test",
  "pages": "pages",
  "sections": "sections",
  "components": "components",
  "assets": "assets",
  "styles": "styles",
  "scripts": "scripts",
  "config": "config"
}
JSON

"${PROJECT_ROOT}/core/static-runtime/engine/validate-static-website.sh" \
    "${OUTPUT}" >/dev/null

echo "PASS: Static website validation"

"${PROJECT_ROOT}/core/static-runtime/engine/load-static-website.sh" \
    "${OUTPUT}" >/dev/null

echo "PASS: Static website loading"

rm -rf "${OUTPUT}/assets"

if "${PROJECT_ROOT}/core/static-runtime/engine/validate-static-website.sh" \
    "${OUTPUT}" >/dev/null 2>&1; then
    echo "FAIL: Invalid static website was accepted"
    exit 1
fi

echo "PASS: Invalid output rejection"

echo
echo "PASS: Static Website Runtime"
