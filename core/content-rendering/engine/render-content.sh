#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
RESOLVER="${PROJECT_ROOT}/core/content-rendering/engine/content-resolver.sh"

source "${RESOLVER}"

WEBSITE_TYPE="${1:-}"

if [[ -z "${WEBSITE_TYPE}" ]]; then
    echo "ERROR: Website type is required" >&2
    exit 1
fi

PROFILE_DIR="$(resolve_content_profile "${WEBSITE_TYPE}")"
PROFILE_FILE="${PROFILE_DIR}/profile.json"

[[ -f "${PROFILE_FILE}" ]] || {
    echo "ERROR: Content profile not found: ${PROFILE_FILE}" >&2
    exit 1
}

python3 - "${PROFILE_FILE}" "${WEBSITE_TYPE}" <<'PY'
import json
import sys
from pathlib import Path

profile_file = Path(sys.argv[1])
website_type = sys.argv[2]

with profile_file.open() as f:
    profile = json.load(f)

output = {
    "website_type": website_type,
    "source": str(profile_file),
    "status": "renderable",
    "content": profile,
}

print(json.dumps(output, indent=2))
PY
