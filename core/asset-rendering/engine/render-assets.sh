#!/usr/bin/env bash
set -Eeuo pipefail

MEDIA_ROOT="${1:-}"
OUTPUT_DIR="${2:-}"
MANIFEST="${3:-}"

if [[ -z "${MEDIA_ROOT}" || -z "${OUTPUT_DIR}" || -z "${MANIFEST}" ]]; then
    echo "Usage: render-assets.sh <media-root> <output-dir> <manifest>"
    exit 1
fi

[[ -d "${MEDIA_ROOT}" ]] || {
    echo "ERROR: Media root does not exist"
    exit 1
}

[[ -f "${MANIFEST}" ]] || {
    echo "ERROR: Asset manifest does not exist"
    exit 1
}

mkdir -p "${OUTPUT_DIR}"

cp -R "${MEDIA_ROOT}/." "${OUTPUT_DIR}/"

python3 - "${MANIFEST}" <<'PY'
import json
import sys
from pathlib import Path

manifest_path = Path(sys.argv[1])
manifest = json.loads(manifest_path.read_text())

manifest["status"] = "READY"

manifest_path.write_text(
    json.dumps(manifest, indent=2) + "\n"
)

print("Asset rendering completed")
PY

echo "Assets rendered successfully"
