#!/usr/bin/env bash
set -Eeuo pipefail

AUDIT_FILE="${1:-}"

if [[ -z "${AUDIT_FILE}" ]]; then
    echo "ERROR: Orchestration audit file is required"
    exit 1
fi

if [[ ! -f "${AUDIT_FILE}" ]]; then
    echo "ERROR: Orchestration audit file does not exist"
    exit 1
fi

python3 - "${AUDIT_FILE}" <<'PY'
import json
import sys
from pathlib import Path

audit_path = Path(sys.argv[1])
record = json.loads(audit_path.read_text())

status = record.get("status")
events = record.get("events", [])

if status == "complete":
    print("recovery_status=not_required")
    print("final_state=ORCHESTRATION_COMPLETED")
    raise SystemExit(0)

if status != "failed":
    raise SystemExit("ERROR: Unsupported orchestration status")

completed = [
    event["stage"]
    for event in events
    if event.get("status") == "completed"
]

failed = [
    event["stage"]
    for event in events
    if event.get("status") == "failed"
]

if not failed:
    raise SystemExit("ERROR: Failed orchestration has no failed stage")

failed_stage = failed[-1]

recovery = {
    "orchestration_id": record["orchestration_id"],
    "recovery_status": "recoverable",
    "last_completed_stage": completed[-1] if completed else None,
    "failed_stage": failed_stage,
    "resume_from": failed_stage,
    "final_state": "ORCHESTRATION_RECOVERABLE",
}

recovery_path = audit_path.with_name(
    audit_path.stem + "-recovery.json"
)

recovery_path.write_text(
    json.dumps(recovery, indent=2) + "\n"
)

print("orchestration-recovery-ready")
print(f"recovery_file={recovery_path}")
print(f"last_completed_stage={recovery['last_completed_stage']}")
print(f"failed_stage={failed_stage}")
print("recovery_status=recoverable")
PY
