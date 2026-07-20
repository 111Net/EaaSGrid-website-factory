#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

AUDIT_FILE="${1:-}"
DEPLOYMENT="${2:-}"

if [[ -z "${AUDIT_FILE}" || -z "${DEPLOYMENT}" ]]; then
    echo "ERROR: Usage: recover-deployment-lifecycle.sh <audit_file> <deployment_path>"
    exit 1
fi

if [[ ! -f "${AUDIT_FILE}" ]]; then
    echo "ERROR: Audit record does not exist"
    exit 1
fi

if [[ ! -d "${DEPLOYMENT}" ]]; then
    echo "ERROR: Deployment does not exist"
    exit 1
fi

python3 - \
    "${AUDIT_FILE}" \
    "${DEPLOYMENT}" <<'PY'
import json
import sys
from pathlib import Path

audit_file = Path(sys.argv[1])
deployment = Path(sys.argv[2])

record = json.loads(audit_file.read_text())

deployment_record = deployment / "deployment-record.json"

if not deployment_record.exists():
    raise SystemExit("ERROR: Deployment record missing")

deployment_data = json.loads(deployment_record.read_text())

lifecycle_status = record.get("lifecycle_status")
final_state = record.get("final_state")

if lifecycle_status == "complete" and final_state == "COMPLETED":
    deployment_data["recovery_status"] = "RECOVERED"
    deployment_data["recovered_from_state"] = final_state

elif lifecycle_status == "rolled_back" and final_state == "ROLLED_BACK":
    deployment_data["recovery_status"] = "ROLLED_BACK"
    deployment_data["recovered_from_state"] = final_state

else:
    raise SystemExit(
        f"ERROR: Unsupported lifecycle recovery state: "
        f"{lifecycle_status}/{final_state}"
    )

deployment_record.write_text(
    json.dumps(deployment_data, indent=2) + "\n"
)

print("deployment-lifecycle-recovered")
print(f"deployment_id={record['deployment_id']}")
print(f"recovery_status={deployment_data['recovery_status']}")
print(f"recovered_from_state={deployment_data['recovered_from_state']}")
PY
