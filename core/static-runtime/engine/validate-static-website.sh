#!/usr/bin/env bash
set -Eeuo pipefail

OUTPUT_ROOT="${1:-}"

if [[ -z "${OUTPUT_ROOT}" ]]; then
    echo "ERROR: Website output path is required" >&2
    exit 1
fi

required_paths=(
    "manifest.json"
    "pages"
    "sections"
    "components"
    "assets"
    "styles"
    "scripts"
    "config"
)

for path in "${required_paths[@]}"; do
    if [[ ! -e "${OUTPUT_ROOT}/${path}" ]]; then
        echo "ERROR: Missing static website output: ${path}" >&2
        exit 1
    fi
done

echo "Static website validation successful"
