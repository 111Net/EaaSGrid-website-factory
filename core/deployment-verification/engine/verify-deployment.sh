#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

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
MANIFEST="${DEPLOYMENT}/deployment-manifest.json"
TARGET="${DEPLOYMENT}/deployment-target.json"

for file in "${RECORD}" "${MANIFEST}" "${TARGET}"; do
    [[ -f "${file}" ]] || {
        echo "ERROR: Required deployment artifact missing: ${file}"
        exit 1
    }
done

python3 - "${RECORD}" "${MANIFEST}" "${TARGET}" <<'PY'
import json
import sys
from pathlib import Path

record_path = Path(sys.argv[1])
manifest_path = Path(sys.argv[2])
target_path = Path(sys.argv[3])

record = json.loads(record_path.read_text())
manifest = json.loads(manifest_path.read_text())
target = json.loads(target_path.read_text())

required_record = [
    "deployment_id",
    "website_id",
    "environment",
    "version",
    "target_path",
    "deployment_status",
]

required_manifest = [
    "website_id",
    "environment",
    "version",
    "package_status",
]

required_target = [
    "website_id",
    "environment",
    "version",
    "target_path",
    "target_status",
]

for field in required_record:
    if field not in record:
        raise SystemExit(f"ERROR: Missing deployment record field: {field}")

for field in required_manifest:
    if field not in manifest:
        raise SystemExit(f"ERROR: Missing deployment manifest field: {field}")

for field in required_target:
    if field not in target:
        raise SystemExit(f"ERROR: Missing deployment target field: {field}")

if record["deployment_status"] != "deployed":
    raise SystemExit("ERROR: Deployment is not in deployed state")

if manifest["package_status"] != "ready":
    raise SystemExit("ERROR: Deployment package is not ready")

if target["target_status"] not in {"available", "resolved"}:
    raise SystemExit("ERROR: Deployment target is not available or resolved")

if record["website_id"] != manifest["website_id"]:
    raise SystemExit("ERROR: Website ID mismatch between record and package")

if record["website_id"] != target["website_id"]:
    raise SystemExit("ERROR: Website ID mismatch between record and target")

if record["environment"] != manifest["environment"]:
    raise SystemExit("ERROR: Environment mismatch between record and package")

if record["environment"] != target["environment"]:
    raise SystemExit("ERROR: Environment mismatch between record and target")

if record["version"] != manifest["version"]:
    raise SystemExit("ERROR: Version mismatch between record and package")

if record["version"] != target["version"]:
    raise SystemExit("ERROR: Version mismatch between record and target")

if record["target_path"] != target["target_path"]:
    raise SystemExit("ERROR: Target path mismatch")

print("deployment-structure-valid")
PY

echo "deployment-verified"
echo "deployment_id=$(python3 - "${RECORD}" <<'PY'
import json
import sys
print(json.loads(open(sys.argv[1]).read())["deployment_id"])
PY
)"

echo "verification_status=verified"
