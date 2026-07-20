#!/usr/bin/env bash
set -Eeuo pipefail

DEPLOYMENT="${1:-}"

if [[ -z "${DEPLOYMENT}" ]]; then
    echo "ERROR: Deployment path required"
    exit 1
fi

[[ -d "${DEPLOYMENT}" ]] || {
    echo "invalid"
    exit 1
}

[[ -f "${DEPLOYMENT}/deployment-record.json" ]] || {
    echo "invalid"
    exit 1
}

python3 - "${DEPLOYMENT}/deployment-record.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = json.loads(path.read_text())

required = [
    "deployment_id",
    "website_id",
    "environment",
    "version",
    "target_path",
    "deployment_status",
]

for field in required:
    if field not in data:
        raise SystemExit(1)

if data["deployment_status"] != "deployed":
    raise SystemExit(1)

print("valid")
PY
