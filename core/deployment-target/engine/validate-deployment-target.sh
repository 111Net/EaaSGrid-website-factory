#!/usr/bin/env bash
set -Eeuo pipefail

TARGET_FILE="${1:-}"

if [[ -z "${TARGET_FILE}" ]]; then
    echo "ERROR: Deployment target file required"
    exit 1
fi

[[ -f "${TARGET_FILE}" ]] || {
    echo "invalid"
    exit 1
}

python3 - "${TARGET_FILE}" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = json.loads(path.read_text())

required = [
    "website_id",
    "environment",
    "version",
    "target_id",
    "target_type",
    "target_path",
    "target_status",
]

for field in required:
    if field not in data:
        raise SystemExit(1)

if data["environment"] not in {"local", "staging", "production"}:
    raise SystemExit(1)

if data["target_status"] != "resolved":
    raise SystemExit(1)

print("valid")
PY
