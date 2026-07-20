#!/usr/bin/env bash
set -Eeuo pipefail

AUDIT_FILE="${1:-}"
ORCHESTRATION_ID="${2:-}"
STATUS="${3:-}"
FINAL_STATE="${4:-}"
EVENTS_JSON="${5:-}"

if [[ -z "${AUDIT_FILE}" ||
      -z "${ORCHESTRATION_ID}" ||
      -z "${STATUS}" ||
      -z "${FINAL_STATE}" ||
      -z "${EVENTS_JSON}" ]]; then
    echo "ERROR: Missing orchestration audit arguments"
    exit 1
fi

mkdir -p "$(dirname "${AUDIT_FILE}")"

python3 - \
    "${AUDIT_FILE}" \
    "${ORCHESTRATION_ID}" \
    "${STATUS}" \
    "${FINAL_STATE}" \
    "${EVENTS_JSON}" <<'PY'
import json
import sys
from pathlib import Path

(
    audit_file,
    orchestration_id,
    status,
    final_state,
    events_json,
) = sys.argv[1:]

events = json.loads(events_json)

record = {
    "orchestration_id": orchestration_id,
    "status": status,
    "final_state": final_state,
    "events": events,
}

Path(audit_file).write_text(
    json.dumps(record, indent=2) + "\n"
)

print("orchestration-audit-recorded")
print(f"audit_file={audit_file}")
print(f"orchestration_id={orchestration_id}")
print(f"final_state={final_state}")
PY
