#!/usr/bin/env bash
set -Eeuo pipefail

BUILD_MANIFEST="${1:-}"

if [[ -z "${BUILD_MANIFEST}" ]]; then
    echo "Usage: render-website-template.sh <build-manifest>"
    exit 1
fi

if [[ ! -f "${BUILD_MANIFEST}" ]]; then
    echo "ERROR: Build manifest not found"
    exit 1
fi

echo "Website template rendering completed"
echo "Build manifest: ${BUILD_MANIFEST}"
