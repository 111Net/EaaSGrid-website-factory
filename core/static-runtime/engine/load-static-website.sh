#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
OUTPUT_ROOT="${1:-}"

if [[ -z "${OUTPUT_ROOT}" ]]; then
    echo "ERROR: Website output path is required" >&2
    exit 1
fi

if [[ ! -d "${OUTPUT_ROOT}" ]]; then
    echo "ERROR: Website output does not exist: ${OUTPUT_ROOT}" >&2
    exit 1
fi

MANIFEST="${OUTPUT_ROOT}/manifest.json"

if [[ ! -f "${MANIFEST}" ]]; then
    echo "ERROR: Website manifest not found: ${MANIFEST}" >&2
    exit 1
fi

python3 - "${MANIFEST}" <<'PY'
import json
import sys
from pathlib import Path

manifest = Path(sys.argv[1])

with manifest.open() as f:
    data = json.load(f)

required = [
    "website",
    "pages",
    "sections",
    "components",
    "assets",
    "styles",
    "scripts",
    "config",
]

missing = [key for key in required if key not in data]

if missing:
    raise SystemExit(
        "ERROR: Static website manifest missing: "
        + ", ".join(missing)
    )

print("Static website loaded successfully")
print(f"Website: {data['website']}")
print("Runtime status: READY")
PY
