#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

MEDIA_ROOT="${1:-}"
OUTPUT_MANIFEST="${2:-}"

if [[ -z "${MEDIA_ROOT}" || -z "${OUTPUT_MANIFEST}" ]]; then
    echo "Usage: resolve-assets.sh <media-root> <manifest>"
    exit 1
fi

[[ -d "${MEDIA_ROOT}" ]] || {
    echo "ERROR: Media root does not exist"
    exit 1
}

mkdir -p "$(dirname "${OUTPUT_MANIFEST}")"

python3 - "${MEDIA_ROOT}" "${OUTPUT_MANIFEST}" <<'PY'
import json
import sys
from pathlib import Path

media_root = Path(sys.argv[1])
output_manifest = Path(sys.argv[2])

supported = {
    ".jpg", ".jpeg", ".png", ".webp",
    ".gif", ".svg", ".avif",
    ".mp4", ".webm", ".mov",
    ".mp3", ".wav", ".ogg"
}

assets = []

for path in sorted(media_root.rglob("*")):
    if path.is_file():
        extension = path.suffix.lower()

        if extension in supported:
            relative = path.relative_to(media_root)

            if extension in {".jpg", ".jpeg", ".png", ".webp", ".gif", ".svg", ".avif"}:
                asset_type = "image"
            elif extension in {".mp4", ".webm", ".mov"}:
                asset_type = "video"
            else:
                asset_type = "audio"

            assets.append({
                "name": path.name,
                "path": str(relative),
                "type": asset_type,
                "extension": extension
            })

manifest = {
    "engine": "EaaSGrid Website Factory",
    "asset_system": "media-rendering",
    "status": "RESOLVED",
    "asset_count": len(assets),
    "assets": assets
}

output_manifest.write_text(
    json.dumps(manifest, indent=2) + "\n"
)

print(f"Resolved {len(assets)} assets")
PY
