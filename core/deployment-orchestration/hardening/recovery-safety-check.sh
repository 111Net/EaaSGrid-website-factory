#!/usr/bin/env bash

set -Eeuo pipefail

RECOVERY_FILE="${1:-}"

if [[ -z "${RECOVERY_FILE}" ]]; then
    echo "ERROR: recovery file required"
    exit 1
fi


echo "=== RECOVERY SAFETY CHECK ==="

if [[ ! -f "${RECOVERY_FILE}" ]]; then
    echo "ERROR: recovery state missing"
    exit 1
fi


python3 - "${RECOVERY_FILE}" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    data=json.load(f)

assert data.get("recovery_status") == "recoverable"
assert data.get("resume_from")

print("recovery_state_valid=true")
PY

echo "recovery_safety=PASS"

