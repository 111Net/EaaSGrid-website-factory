#!/usr/bin/env bash
set -Eeuo pipefail

LIFECYCLE_AUDIT="${1:-}"

if [[ -z "${LIFECYCLE_AUDIT}" ]]; then
    echo "ERROR: lifecycle audit required"
    exit 1
fi

if [[ ! -f "${LIFECYCLE_AUDIT}" ]]; then
    echo "ERROR: lifecycle audit missing"
    exit 1
fi


python3 - "${LIFECYCLE_AUDIT}" <<'PY'
import json
import sys
from pathlib import Path

source = Path(sys.argv[1])

record = json.loads(source.read_text())

deployment_id = record.get("deployment_id")

status = record.get("lifecycle_status")

transitions = record.get("transitions", [])


events=[]

for t in transitions:
    events.append({
        "stage": t["to"],
        "status": "completed"
    })


if status == "rolled_back":
    events.append({
        "stage": record.get("final_state"),
        "status": "failed"
    })

elif status == "complete":
    orchestration_status="complete"
else:
    orchestration_status="failed"


if status == "rolled_back":
    orchestration_status="failed"

output={
    "orchestration_id": deployment_id,
    "status": orchestration_status,
    "events": events
}


target = source.with_name(
    source.stem + "-orchestration.json"
)

target.write_text(
    json.dumps(output, indent=2)+"\n"
)

print("translation_complete")
print(f"orchestration_audit={target}")
print(f"status={orchestration_status}")
PY
