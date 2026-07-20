#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
REGISTRY="${PROJECT_ROOT}/data/environment-manager/environment-registry.json"

ENVIRONMENT_ID="${1:-}"
WEBSITE_ID="${2:-}"
PREVIEW_ID="${3:-}"

[[ -n "${ENVIRONMENT_ID}" ]] || {
    echo "ERROR: Environment ID is required"
    exit 1
}

[[ -n "${WEBSITE_ID}" ]] || {
    echo "ERROR: Website ID is required"
    exit 1
}

[[ -n "${PREVIEW_ID}" ]] || {
    echo "ERROR: Preview ID is required"
    exit 1
}

mkdir -p "$(dirname "${REGISTRY}")"

if [[ ! -f "${REGISTRY}" ]]; then
    printf '{\n  "environments": []\n}\n' > "${REGISTRY}"
fi

python3 - "${REGISTRY}" "${ENVIRONMENT_ID}" "${WEBSITE_ID}" "${PREVIEW_ID}" <<'PY'
import json
import sys
from pathlib import Path

registry_path = Path(sys.argv[1])
environment_id = sys.argv[2]
website_id = sys.argv[3]
preview_id = sys.argv[4]

data = json.loads(registry_path.read_text())

for environment in data["environments"]:
    if environment["environment_id"] == environment_id:
        print(f"ERROR: Environment already exists: {environment_id}")
        sys.exit(1)

data["environments"].append({
    "environment_id": environment_id,
    "website_id": website_id,
    "preview_id": preview_id,
    "status": "created"
})

registry_path.write_text(json.dumps(data, indent=2) + "\n")

print(f"Environment created successfully: {environment_id}")
PY
