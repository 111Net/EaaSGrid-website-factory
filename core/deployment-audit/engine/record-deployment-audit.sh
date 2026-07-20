#!/usr/bin/env bash
set -Eeuo pipefail

AUDIT_FILE="${1:-}"
DEPLOYMENT_ID="${2:-}"
WEBSITE_ID="${3:-}"
ENVIRONMENT="${4:-}"
VERSION="${5:-}"
LIFECYCLE_STATUS="${6:-}"
FINAL_STATE="${7:-}"
TRANSITIONS_JSON="${8:-}"

if [[ -z "${AUDIT_FILE}" ||
      -z "${DEPLOYMENT_ID}" ||
      -z "${WEBSITE_ID}" ||
      -z "${ENVIRONMENT}" ||
      -z "${VERSION}" ||
      -z "${LIFECYCLE_STATUS}" ||
      -z "${FINAL_STATE}" ||
      -z "${TRANSITIONS_JSON}" ]]; then
    echo "ERROR: Missing audit recorder arguments"
    exit 1
fi

mkdir -p "$(dirname "${AUDIT_FILE}")"

python3 - \
    "${AUDIT_FILE}" \
    "${DEPLOYMENT_ID}" \
    "${WEBSITE_ID}" \
    "${ENVIRONMENT}" \
    "${VERSION}" \
    "${LIFECYCLE_STATUS}" \
    "${FINAL_STATE}" \
    "${TRANSITIONS_JSON}" <<'PY'
import json
import sys
from pathlib import Path

(
    audit_file,
    deployment_id,
    website_id,
    environment,
    version,
    lifecycle_status,
    final_state,
    transitions_json,
) = sys.argv[1:]

transitions = json.loads(transitions_json)

record = {
    "deployment_id": deployment_id,
    "website_id": website_id,
    "environment": environment,
    "version": version,
    "lifecycle_status": lifecycle_status,
    "final_state": final_state,
    "transitions": transitions,
}

Path(audit_file).write_text(
    json.dumps(record, indent=2) + "\n"
)

print("deployment-audit-recorded")
print(f"audit_file={audit_file}")
print(f"deployment_id={deployment_id}")
print(f"final_state={final_state}")
PY
