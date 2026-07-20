#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${PROJECT_ROOT}"

source core/content-rendering/engine/content-resolver.sh

echo "=== CONTENT RENDERING ENGINE TESTS ==="

for website_type in \
    auto-mechanic \
    systems-integrator \
    personal \
    trades-services
do
    profile="$(resolve_content_profile "${website_type}")"

    [[ -f "${profile}/profile.json" ]] || {
        echo "FAIL: ${website_type} content profile"
        exit 1
    }

    echo "PASS: ${website_type} content resolution"
done

output="$(core/content-rendering/engine/render-content.sh auto-mechanic)"

echo "${output}" | grep -q '"website_type": "auto-mechanic"'
echo "PASS: Auto Mechanic content rendering"

echo "${output}" | grep -q '"status": "renderable"'
echo "PASS: Renderable content output"

echo "${output}" | grep -q '"content"'
echo "PASS: Content output"

for website_type in \
    systems-integrator \
    personal \
    trades-services
do
    output="$(core/content-rendering/engine/render-content.sh "${website_type}")"

    echo "${output}" | grep -q '"status": "renderable"'

    echo "PASS: ${website_type} content rendering"
done

if core/content-rendering/engine/render-content.sh unsupported >/dev/null 2>&1; then
    echo "FAIL: Unsupported website type accepted"
    exit 1
fi

echo "PASS: Unsupported website type rejection"

echo
echo "PASS: Content Rendering Engine"
