#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
RESOLVER="${PROJECT_ROOT}/core/component-assembly/engine/component-resolver.sh"

assemble_components() {
    local input_file="$1"
    local output_file="$2"

    [[ -f "${input_file}" ]] || {
        echo "ERROR: Input composition file not found: ${input_file}" >&2
        return 1
    }

    python3 - "${input_file}" "${output_file}" "${RESOLVER}" <<'PY'
import json
import subprocess
import sys

input_file = sys.argv[1]
output_file = sys.argv[2]
resolver = sys.argv[3]

with open(input_file, "r", encoding="utf-8") as file:
    composition = json.load(file)

components = composition.get("components", [])

if not components:
    raise SystemExit("ERROR: No components provided")

assembled = []

for index, component_id in enumerate(components, start=1):
    result = subprocess.run(
        [resolver, component_id],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        raise SystemExit(result.stderr.strip())

    component = json.loads(result.stdout)
    component["order"] = index
    assembled.append(component)

result = {
    "assembly": {
        "type": "component-assembly",
        "component_count": len(assembled),
        "components": assembled
    }
}

with open(output_file, "w", encoding="utf-8") as file:
    json.dump(result, file, indent=2)

print(f"Components assembled successfully: {len(assembled)}")
PY
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    assemble_components "${1:-}" "${2:-}"
fi
