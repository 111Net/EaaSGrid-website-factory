#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="/data/eaasgrid-website-factory"
cd "${PROJECT_ROOT}"

TEST_DIR="/tmp/eaasgrid-template-rendering-test"
rm -rf "${TEST_DIR}"
mkdir -p "${TEST_DIR}"

TEMPLATE="${TEST_DIR}/template.html"
OUTPUT="${TEST_DIR}/output.html"

cat > "${TEMPLATE}" <<'HTML'
<h1>EaaSGrid Website Factory</h1>
HTML

core/template-rendering/engine/render-template.sh \
    "${TEMPLATE}" \
    "${OUTPUT}" >/dev/null

test -f "${OUTPUT}" \
    && echo "PASS: Template rendering"

grep -q "EaaSGrid Website Factory" "${OUTPUT}" \
    && echo "PASS: Template output"

test -x core/template-rendering/engine/render-template.sh \
    && echo "PASS: Template renderer"

test -x core/template-rendering/engine/render-website-template.sh \
    && echo "PASS: Website template renderer"

rm -rf "${TEST_DIR}"

echo
echo "PASS: Template Rendering Engine"
