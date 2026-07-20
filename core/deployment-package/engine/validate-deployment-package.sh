#!/usr/bin/env bash
set -Eeuo pipefail

PACKAGE="${1:-}"

if [[ -z "${PACKAGE}" ]]; then
    echo "ERROR: Package path required"
    exit 1
fi

[[ -d "${PACKAGE}" ]] || {
    echo "invalid"
    exit 1
}

[[ -f "${PACKAGE}/deployment-manifest.json" ]] || {
    echo "invalid"
    exit 1
}

python3 - "${PACKAGE}/deployment-manifest.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = json.loads(path.read_text())

required = [
    "website_id",
    "environment",
    "version",
    "package_status",
    "deployment_status",
]

for field in required:
    if field not in data:
        raise SystemExit(1)

if data["package_status"] != "ready":
    raise SystemExit(1)

print("valid")
PY
