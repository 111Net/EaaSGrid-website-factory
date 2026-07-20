#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

PACKAGE="${1:-}"
TARGET="${2:-}"

if [[ -z "${PACKAGE}" || -z "${TARGET}" ]]; then
    echo "ERROR: Package and target paths are required"
    exit 1
fi

[[ -d "${PACKAGE}" ]] || {
    echo "ERROR: Deployment package does not exist"
    exit 1
}

[[ -d "${TARGET}" ]] || {
    echo "ERROR: Deployment target does not exist"
    exit 1
}

[[ -f "${PACKAGE}/deployment-manifest.json" ]] || {
    echo "ERROR: Deployment manifest missing"
    exit 1
}

[[ -f "${TARGET}/deployment-target.json" ]] || {
    echo "ERROR: Deployment target manifest missing"
    exit 1
}

python3 - \
    "${PACKAGE}/deployment-manifest.json" \
    "${TARGET}/deployment-target.json" <<'PY'
import json
import sys
from pathlib import Path

package_path = Path(sys.argv[1])
target_path = Path(sys.argv[2])

package = json.loads(package_path.read_text())
target = json.loads(target_path.read_text())

required_package = [
    "website_id",
    "environment",
    "version",
    "package_status",
    "deployment_status",
]

required_target = [
    "website_id",
    "environment",
    "target_type",
    "target_path",
    "target_status",
]

for field in required_package:
    if field not in package:
        raise SystemExit(f"ERROR: Missing package field: {field}")

for field in required_target:
    if field not in target:
        raise SystemExit(f"ERROR: Missing target field: {field}")

if package["package_status"] != "ready":
    raise SystemExit("ERROR: Deployment package is not ready")

if target["target_status"] not in {"available", "resolved"}:
    raise SystemExit("ERROR: Deployment target is not available or resolved")

if package["website_id"] != target["website_id"]:
    raise SystemExit("ERROR: Website ID mismatch")

if package["environment"] != target["environment"]:
    raise SystemExit("ERROR: Deployment environment mismatch")
PY

WEBSITE_ID="$(
    python3 - "${PACKAGE}/deployment-manifest.json" <<'PY'
import json
import sys

with open(sys.argv[1]) as file:
    print(json.load(file)["website_id"])
PY
)"

ENVIRONMENT="$(
    python3 - "${PACKAGE}/deployment-manifest.json" <<'PY'
import json
import sys

with open(sys.argv[1]) as file:
    print(json.load(file)["environment"])
PY
)"

VERSION="$(
    python3 - "${PACKAGE}/deployment-manifest.json" <<'PY'
import json
import sys

with open(sys.argv[1]) as file:
    print(json.load(file)["version"])
PY
)"

TARGET_PATH="$(
    python3 - "${TARGET}/deployment-target.json" <<'PY'
import json
import sys

with open(sys.argv[1]) as file:
    print(json.load(file)["target_path"])
PY
)"

DEPLOYMENT_ID="${WEBSITE_ID}-${VERSION}-${ENVIRONMENT}"

DEPLOYMENT_ROOT="${PROJECT_ROOT}/data/deployment-executor/deployments/${DEPLOYMENT_ID}"

mkdir -p "${DEPLOYMENT_ROOT}"

cp "${PACKAGE}/deployment-manifest.json" \
    "${DEPLOYMENT_ROOT}/deployment-manifest.json"

cp "${TARGET}/deployment-target.json" \
    "${DEPLOYMENT_ROOT}/deployment-target.json"

cat > "${DEPLOYMENT_ROOT}/deployment-record.json" <<EOF
{
  "deployment_id": "${DEPLOYMENT_ID}",
  "website_id": "${WEBSITE_ID}",
  "environment": "${ENVIRONMENT}",
  "version": "${VERSION}",
  "target_path": "${TARGET_PATH}",
  "deployment_status": "deployed"
}
EOF

echo "deployment-complete"
echo "deployment_id=${DEPLOYMENT_ID}"
echo "website_id=${WEBSITE_ID}"
echo "environment=${ENVIRONMENT}"
echo "version=${VERSION}"
echo "target_path=${TARGET_PATH}"
echo "deployment_record=${DEPLOYMENT_ROOT}/deployment-record.json"
