#!/usr/bin/env bash
set -Eeuo pipefail

RECOVERY_FILE="${1:-}"

if [[ -z "${RECOVERY_FILE}" ]]; then
    echo "ERROR: Recovery file required"
    exit 1
fi

if [[ ! -f "${RECOVERY_FILE}" ]]; then
    echo "ERROR: Recovery file does not exist"
    exit 1
fi


python3 - "${RECOVERY_FILE}" <<'PY'

import json
import sys
from pathlib import Path


path = Path(sys.argv[1])

recovery = json.loads(path.read_text())


status = recovery.get("recovery_status")
resume_from = recovery.get("resume_from")
failed_stage = recovery.get("failed_stage")


if status != "recoverable":
    raise SystemExit(
        "ERROR: Recovery state not resumable"
    )


resume = {
    "orchestration_id": recovery["orchestration_id"],
    "resume_status": "ready",
    "failed_stage": failed_stage,
    "resume_from": resume_from,
    "final_state": "ORCHESTRATION_RESUME_READY"
}


output = path.with_name(
    path.stem + "-resume.json"
)


output.write_text(
    json.dumps(resume, indent=2) + "\n"
)


print("orchestration-resume-ready")
print(f"resume_file={output}")
print(f"resume_from={resume_from}")
print("resume_status=ready")

PY
