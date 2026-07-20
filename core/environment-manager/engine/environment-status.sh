#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
REGISTRY="${PROJECT_ROOT}/data/environment-manager/environment-registry.json"

ENVIRONMENT_ID="${1:-}"

[[ -n "${ENVIRONMENT_ID}" ]] || {
    echo "ERROR: Environment ID is required"
    exit 1
}

[[ -f "${REGISTRY}" ]] || {
    echo "ERROR: Environment registry not found"
    exit 1
}

python3 - "${REGISTRY}" "${ENVIRONMENT_ID}" <<'PY'
import json
import sys
from pathlib import Path

registry_path = Path(sys.argv[1])
environment_id = sys.argv[2]

data = json.loads(registry_path.read_text())

for environment in data["environments"]:
    if environment["environment_id"] == environment_id:
        print(environment["status"])
        sys.exit(0)

print(f"ERROR: Environment not found: {environment_id}")
sys.exit(1)
PY
