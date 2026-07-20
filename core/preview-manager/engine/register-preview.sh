#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
REGISTRY="${PROJECT_ROOT}/data/preview-manager/preview-registry.json"

PREVIEW_ID="${1:-}"
WEBSITE_ID="${2:-}"
WEBSITE_OUTPUT="${3:-}"

[[ -n "${PREVIEW_ID}" ]] || {
    echo "ERROR: Preview ID is required"
    exit 1
}

[[ -n "${WEBSITE_ID}" ]] || {
    echo "ERROR: Website ID is required"
    exit 1
}

[[ -n "${WEBSITE_OUTPUT}" ]] || {
    echo "ERROR: Website output path is required"
    exit 1
}

mkdir -p "$(dirname "${REGISTRY}")"

if [[ ! -f "${REGISTRY}" ]]; then
    printf '{\n  "previews": []\n}\n' > "${REGISTRY}"
fi

python3 - "${REGISTRY}" "${PREVIEW_ID}" "${WEBSITE_ID}" "${WEBSITE_OUTPUT}" <<'PY'
import json
import sys
from pathlib import Path

registry_path = Path(sys.argv[1])
preview_id = sys.argv[2]
website_id = sys.argv[3]
website_output = sys.argv[4]

data = json.loads(registry_path.read_text())

for preview in data["previews"]:
    if preview["preview_id"] == preview_id:
        print(f"ERROR: Preview already registered: {preview_id}")
        sys.exit(1)

data["previews"].append({
    "preview_id": preview_id,
    "website_id": website_id,
    "website_output": website_output,
    "status": "registered"
})

registry_path.write_text(json.dumps(data, indent=2) + "\n")

print(f"Preview registered successfully: {preview_id}")
PY
