#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

RESOLVER="${PROJECT_ROOT}/core/asset-rendering/engine/resolve-assets.sh"
RENDERER="${PROJECT_ROOT}/core/asset-rendering/engine/render-assets.sh"

TEST_ROOT="${PROJECT_ROOT}/.test-asset-rendering"
MEDIA_ROOT="${TEST_ROOT}/media"
OUTPUT_DIR="${TEST_ROOT}/output"
MANIFEST="${TEST_ROOT}/manifest.json"

rm -rf "${TEST_ROOT}"

mkdir -p "${MEDIA_ROOT}/images"
mkdir -p "${MEDIA_ROOT}/videos"
mkdir -p "${MEDIA_ROOT}/audio"

printf 'image' > "${MEDIA_ROOT}/images/logo.png"
printf 'image' > "${MEDIA_ROOT}/images/hero.webp"
printf 'video' > "${MEDIA_ROOT}/videos/demo.mp4"
printf 'audio' > "${MEDIA_ROOT}/audio/intro.mp3"

"${RESOLVER}" "${MEDIA_ROOT}" "${MANIFEST}" >/dev/null

[[ -f "${MANIFEST}" ]] \
    && echo "PASS: Asset manifest generated"

grep -q '"status": "RESOLVED"' "${MANIFEST}" \
    && echo "PASS: Assets resolved"

grep -q '"type": "image"' "${MANIFEST}" \
    && echo "PASS: Image assets resolved"

grep -q '"type": "video"' "${MANIFEST}" \
    && echo "PASS: Video assets resolved"

grep -q '"type": "audio"' "${MANIFEST}" \
    && echo "PASS: Audio assets resolved"

"${RENDERER}" "${MEDIA_ROOT}" "${OUTPUT_DIR}" "${MANIFEST}" >/dev/null

[[ -f "${OUTPUT_DIR}/images/logo.png" ]] \
    && echo "PASS: Image output rendered"

[[ -f "${OUTPUT_DIR}/videos/demo.mp4" ]] \
    && echo "PASS: Video output rendered"

[[ -f "${OUTPUT_DIR}/audio/intro.mp3" ]] \
    && echo "PASS: Audio output rendered"

grep -q '"status": "READY"' "${MANIFEST}" \
    && echo "PASS: Asset lifecycle READY"

rm -rf "${TEST_ROOT}"

echo
echo "PASS: Asset and Media Rendering Engine"
