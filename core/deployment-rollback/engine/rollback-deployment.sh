#!/usr/bin/env bash
set -Eeuo pipefail

DEPLOYMENT="${1:-}"

if [[ -z "${DEPLOYMENT}" ]]; then
    echo "ERROR: Deployment path is required"
    exit 1
fi

if [[ ! -d "${DEPLOYMENT}" ]]; then
    echo "ERROR: Deployment does not exist"
    exit 1
fi

RECORD="${DEPLOYMENT}/deployment-record.json"

if [[ ! -f "${RECORD}" ]]; then
    echo "ERROR: Deployment record missing"
    exit 1
fi

python3 - "${RECORD}" <<'PY'
import json
import sys
from pathlib import Path

record_path = Path(sys.argv[1])
record = json.loads(record_path.read_text())

if record.get("deployment_status") != "deployed":
    raise SystemExit(
        "ERROR: Only deployed deployments can be rolled back"
    )

record["deployment_status"] = "rolled_back"

record_path.write_text(
    json.dumps(record, indent=2) + "\n"
)

print("deployment-rollback-complete")
print(f"deployment_id={record['deployment_id']}")
print("rollback_status=rolled_back")
PY
