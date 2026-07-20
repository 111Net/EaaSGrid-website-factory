#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
REGISTRY="${PROJECT_ROOT}/data/preview-manager/preview-registry.json"

PREVIEW_ID="${1:-}"

[[ -n "${PREVIEW_ID}" ]] || {
    echo "ERROR: Preview ID is required"
    exit 1
}

[[ -f "${REGISTRY}" ]] || {
    echo "ERROR: Preview registry not found"
    exit 1
}

python3 - "${REGISTRY}" "${PREVIEW_ID}" <<'PY'
import json
import sys
from pathlib import Path

registry_path = Path(sys.argv[1])
preview_id = sys.argv[2]

data = json.loads(registry_path.read_text())

for preview in data["previews"]:
    if preview["preview_id"] == preview_id:
        preview["status"] = "stopped"
        registry_path.write_text(json.dumps(data, indent=2) + "\n")
        print(f"Preview stopped successfully: {preview_id}")
        sys.exit(0)

print(f"ERROR: Preview not found: {preview_id}")
sys.exit(1)
PY
