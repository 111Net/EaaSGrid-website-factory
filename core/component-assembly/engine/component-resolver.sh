#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
REGISTRY="${PROJECT_ROOT}/components/registry.json"

resolve_component() {
    local component="$1"

    [[ -n "${component}" ]] || {
        echo "ERROR: Component name is required" >&2
        return 1
    }

    python3 - "${REGISTRY}" "${component}" <<'PY'
import json
import sys

registry_path = sys.argv[1]
component_name = sys.argv[2]

with open(registry_path, "r", encoding="utf-8") as file:
    registry = json.load(file)

components = registry.get("components", [])

for component in components:
    if component.get("id") == component_name:
        print(json.dumps(component))
        sys.exit(0)

print(f"ERROR: Unsupported component: {component_name}", file=sys.stderr)
sys.exit(1)
PY
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    resolve_component "${1:-}"
fi
