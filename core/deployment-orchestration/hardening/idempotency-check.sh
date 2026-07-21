#!/usr/bin/env bash

set -Eeuo pipefail

DEPLOYMENT_ID="${1:-}"

if [[ -z "${DEPLOYMENT_ID}" ]]; then
    echo "ERROR: deployment id required"
    exit 1
fi

STATE_FILE="data/deployment-audit/${DEPLOYMENT_ID}.json"

echo "=== IDEMPOTENCY CHECK ==="

if [[ -f "${STATE_FILE}" ]]; then

    STATUS=$(python3 - "${STATE_FILE}" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    data=json.load(f)

print(data.get("final_state",""))
PY
)

    if [[ "${STATUS}" == "COMPLETED" ]]; then
        echo "duplicate_execution_blocked=true"
        echo "existing_state=COMPLETED"
        exit 0
    fi
fi

echo "duplicate_execution_blocked=false"
echo "idempotency_check=PASS"
