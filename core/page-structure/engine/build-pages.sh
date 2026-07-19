#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CLIENT_ID="${1:-}"

[[ -n "${CLIENT_ID}" ]] || {
    echo "ERROR: Client ID required"
    exit 1
}

CLIENT_ROOT="${PROJECT_ROOT}/clients/${CLIENT_ID}"
PAGES_CONFIG="${CLIENT_ROOT}/pages/pages.json"
GENERATED_PAGES="${CLIENT_ROOT}/generated/pages"

[[ -d "${CLIENT_ROOT}" ]] || {
    echo "ERROR: Client project does not exist"
    exit 1
}

[[ -f "${PAGES_CONFIG}" ]] || {
    echo "ERROR: pages.json does not exist"
    exit 1
}

mkdir -p "${GENERATED_PAGES}"

python - "${PAGES_CONFIG}" "${GENERATED_PAGES}" <<'PY'
import json
import sys
from pathlib import Path

config_path = Path(sys.argv[1])
output_root = Path(sys.argv[2])

data = json.loads(config_path.read_text())

pages = data.get("pages", [])

if not pages:
    raise SystemExit("ERROR: No pages defined")

for page in pages:
    name = page["name"]
    slug = page.get("slug", name.lower().replace(" ", "-"))

    page_dir = output_root / slug
    page_dir.mkdir(parents=True, exist_ok=True)

    page_file = page_dir / "page.json"

    page_file.write_text(
        json.dumps(
            {
                "name": name,
                "slug": slug,
                "type": page.get("type", "page"),
                "sections": page.get("sections", [])
            },
            indent=2
        ) + "\n"
    )

print(f"Generated {len(pages)} pages")
PY

echo "PASS: Page structure generated"
