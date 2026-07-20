#!/usr/bin/env bash
set -Eeuo pipefail

DEPLOYMENT="${1:-}"

if [[ -z "${DEPLOYMENT}" ]]; then
    echo "ERROR: Deployment path is required"
    exit 1
fi

[[ -d "${DEPLOYMENT}" ]] || {
    echo "ERROR: Deployment does not exist"
    exit 1
}

RECORD="${DEPLOYMENT}/deployment-record.json"

[[ -f "${RECORD}" ]] || {
    echo "ERROR: Deployment record missing"
    exit 1
}

python3 - "${RECORD}" <<'PY'
import json
import sys
from pathlib import Path

record = json.loads(Path(sys.argv[1]).read_text())

if record.get("deployment_status") != "deployed":
    raise SystemExit("ERROR: Health gate rejected deployment")

print("health-gate-passed")
print("health_status=healthy")
PY
