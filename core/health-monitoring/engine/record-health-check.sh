#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
REGISTRY="${PROJECT_ROOT}/data/health-monitoring/health-registry.json"

TARGET_ID="${1:-}"
TARGET_TYPE="${2:-}"
HEALTH_STATUS="${3:-}"

[[ -n "${TARGET_ID}" ]] || {
    echo "ERROR: Target ID is required"
    exit 1
}

[[ -n "${TARGET_TYPE}" ]] || {
    echo "ERROR: Target type is required"
    exit 1
}

[[ -n "${HEALTH_STATUS}" ]] || {
    echo "ERROR: Health status is required"
    exit 1
}

case "${HEALTH_STATUS}" in
    healthy|degraded|unhealthy|unknown)
        ;;
    *)
        echo "ERROR: Invalid health status"
        exit 1
        ;;
esac

mkdir -p "$(dirname "${REGISTRY}")"

if [[ ! -f "${REGISTRY}" ]]; then
    printf '{\n  "health_checks": []\n}\n' > "${REGISTRY}"
fi

python3 - "${REGISTRY}" "${TARGET_ID}" "${TARGET_TYPE}" "${HEALTH_STATUS}" <<'PY'
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

registry_path = Path(sys.argv[1])
target_id = sys.argv[2]
target_type = sys.argv[3]
health_status = sys.argv[4]

data = json.loads(registry_path.read_text())

data["health_checks"].append({
    "target_id": target_id,
    "target_type": target_type,
    "status": health_status,
    "checked_at": datetime.now(timezone.utc).isoformat()
})

registry_path.write_text(json.dumps(data, indent=2) + "\n")

print(f"Health check recorded: {target_id} -> {health_status}")
PY
