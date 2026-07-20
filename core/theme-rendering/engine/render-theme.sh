#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
RESOLVER="${PROJECT_ROOT}/core/theme-rendering/engine/theme-resolver.sh"

source "${RESOLVER}"

THEME="${1:-}"

if [[ -z "${THEME}" ]]; then
    echo "ERROR: Theme is required" >&2
    exit 1
fi

THEME_FILE="$(resolve_theme "${THEME}")"

[[ -f "${THEME_FILE}" ]] || {
    echo "ERROR: Theme file not found: ${THEME_FILE}" >&2
    exit 1
}

python3 - "${THEME_FILE}" "${THEME}" <<'PY'
import json
import sys
from pathlib import Path

theme_file = Path(sys.argv[1])
theme_name = sys.argv[2]

with theme_file.open() as f:
    theme = json.load(f)

output = {
    "theme": theme_name,
    "source": str(theme_file),
    "status": "renderable",
    "tokens": theme,
}

print(json.dumps(output, indent=2))
PY
