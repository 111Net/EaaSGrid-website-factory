#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${PROJECT_ROOT}"

source core/theme-rendering/engine/theme-resolver.sh

echo "=== THEME RENDERING ENGINE TESTS ==="

for theme in default modern professional minimal dark custom; do
    file="$(resolve_theme "${theme}")"

    [[ -f "${file}" ]] || {
        echo "FAIL: ${theme} theme resolution"
        exit 1
    }

    echo "PASS: ${theme} theme resolution"
done

output="$(core/theme-rendering/engine/render-theme.sh modern)"

echo "${output}" | grep -q '"theme": "modern"'
echo "PASS: Theme rendering"

echo "${output}" | grep -q '"status": "renderable"'
echo "PASS: Renderable theme output"

echo "${output}" | grep -q '"tokens"'
echo "PASS: Theme tokens"

if core/theme-rendering/engine/render-theme.sh unsupported >/dev/null 2>&1; then
    echo "FAIL: Unsupported theme accepted"
    exit 1
fi

echo "PASS: Unsupported theme rejection"

echo
echo "PASS: Theme Rendering Engine"
