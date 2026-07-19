#!/usr/bin/env bash
set -Eeuo pipefail

validate_config_file() {
    python3 - "$1" <<'PY'
import json
import sys

required = [
    "environment",
    "debug",
    "database_driver",
    "storage_driver",
    "deployment_driver",
    "web_server"
]

with open(sys.argv[1], encoding="utf-8") as f:
    data = json.load(f)

missing = [key for key in required if key not in data]

if missing:
    print("MISSING_KEYS=" + ",".join(missing))
    sys.exit(1)

if data["environment"] not in [
    "development",
    "test",
    "production"
]:
    print("INVALID_ENVIRONMENT")
    sys.exit(1)

print("VALID")
PY
}
