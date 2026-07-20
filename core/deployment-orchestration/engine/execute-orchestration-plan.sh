#!/usr/bin/env bash
set -Eeuo pipefail

PLAN_FILE="${1:-}"

if [[ -z "${PLAN_FILE}" ]]; then
    echo "ERROR: Orchestration plan is required"
    exit 1
fi

if [[ ! -f "${PLAN_FILE}" ]]; then
    echo "ERROR: Orchestration plan does not exist"
    exit 1
fi

python3 - "${PLAN_FILE}" <<'PY'
import json
import os
import sys
from pathlib import Path

plan_path = Path(sys.argv[1])
plan = json.loads(plan_path.read_text())

stages = plan.get("execution_order")

if not isinstance(stages, list) or not stages:
    raise SystemExit("ERROR: Invalid orchestration execution order")

failure_stage = os.environ.get("ORCHESTRATION_FAIL_STAGE", "")

print("=== ORCHESTRATION EXECUTION ===")

for index, stage in enumerate(stages, start=1):
    print(f"STAGE {index}: {stage}")

    if stage == failure_stage:
        print(f"FAIL: Stage {stage}")
        print("STATE: ORCHESTRATION_FAILED")
        print(f"failed_stage={stage}")
        print("orchestration_status=failed")
        raise SystemExit(1)

    print(f"PASS: Executed {stage}")

print("STATE: ORCHESTRATION_COMPLETED")
print("orchestration_status=complete")
PY
