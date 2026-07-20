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
    echo "unknown"
    exit 0
}

python3 - "${REGISTRY}" "${PREVIEW_ID}" <<'PY'
import json
import sys
from pathlib import Path

registry_path = Path(sys.argv[1])
preview_id = sys.argv[2]

data = json.loads(registry_path.read_text())

for preview in data.get("previews", []):
    if preview.get("preview_id") == preview_id:
        status = preview.get("status")

        if status == "running":
            print("healthy")
        elif status in {"registered", "stopped"}:
            print("degraded")
        elif status == "failed":
            print("unhealthy")
        else:
            print("unknown")

        sys.exit(0)

print("unknown")
PY
