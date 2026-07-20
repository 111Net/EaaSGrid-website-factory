#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

WEBSITE_ID="${1:-}"
ENVIRONMENT="${2:-}"
VERSION="${3:-}"

if [[ -z "${WEBSITE_ID}" || -z "${ENVIRONMENT}" || -z "${VERSION}" ]]; then
    echo "ERROR: website_id, environment and version are required"
    exit 1
fi

case "${ENVIRONMENT}" in
    local|staging|production)
        ;;
    *)
        echo "ERROR: Invalid deployment environment"
        exit 1
        ;;
esac

PACKAGE_ROOT="${PROJECT_ROOT}/data/deployment-package/packages/${WEBSITE_ID}/${VERSION}"
REGISTRY="${PROJECT_ROOT}/data/deployment-target/targets/target-registry.json"

[[ -d "${PACKAGE_ROOT}" ]] || {
    echo "ERROR: Deployment package does not exist"
    exit 1
}

[[ -f "${PACKAGE_ROOT}/deployment-manifest.json" ]] || {
    echo "ERROR: Deployment manifest does not exist"
    exit 1
}

[[ -f "${REGISTRY}" ]] || {
    echo "ERROR: Deployment target registry does not exist"
    exit 1
}

TARGET_DATA="$(python3 - "${REGISTRY}" "${ENVIRONMENT}" <<'PY'
import json
import sys
from pathlib import Path

registry = Path(sys.argv[1])
environment = sys.argv[2]

data = json.loads(registry.read_text())

matches = [
    target for target in data.get("targets", [])
    if target.get("environment") == environment
]

if len(matches) != 1:
    raise SystemExit(1)

target = matches[0]

if target.get("status") != "available":
    raise SystemExit(1)

print(json.dumps(target))
PY
)"

TARGET_ID="$(python3 - "${TARGET_DATA}" <<'PY'
import json
import sys

print(json.loads(sys.argv[1])["target_id"])
PY
)"

TARGET_TYPE="$(python3 - "${TARGET_DATA}" <<'PY'
import json
import sys

print(json.loads(sys.argv[1])["target_type"])
PY
)"

TARGET_PATH="$(python3 - "${TARGET_DATA}" <<'PY'
import json
import sys

print(json.loads(sys.argv[1])["target_path"])
PY
)"

cat > "${PACKAGE_ROOT}/deployment-target.json" <<EOF
{
  "website_id": "${WEBSITE_ID}",
  "environment": "${ENVIRONMENT}",
  "version": "${VERSION}",
  "target_id": "${TARGET_ID}",
  "target_type": "${TARGET_TYPE}",
  "target_path": "${TARGET_PATH}",
  "target_status": "resolved"
}
EOF

echo "deployment-target-resolved"
echo "website_id=${WEBSITE_ID}"
echo "environment=${ENVIRONMENT}"
echo "version=${VERSION}"
echo "target_id=${TARGET_ID}"
echo "target_path=${TARGET_PATH}"
