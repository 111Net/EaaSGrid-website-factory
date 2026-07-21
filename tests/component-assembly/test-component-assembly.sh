#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

RESOLVER="${PROJECT_ROOT}/core/component-assembly/engine/component-resolver.sh"
ASSEMBLER="${PROJECT_ROOT}/core/component-assembly/engine/assemble-components.sh"
REGISTRY="${PROJECT_ROOT}/components/registry.json"
SCHEMA="${PROJECT_ROOT}/schemas/component-assembly/component-assembly.schema.json"

echo "=== COMPONENT ASSEMBLY ENGINE TESTS ==="

[[ -x "${RESOLVER}" ]]
echo "PASS: Component resolver"

[[ -x "${ASSEMBLER}" ]]
echo "PASS: Component assembler"

[[ -f "${REGISTRY}" ]]
echo "PASS: Component registry"

[[ -f "${SCHEMA}" ]]
echo "PASS: Component assembly schema"

TEST_DIR="$(mktemp -d)"
trap 'rm -rf "${TEST_DIR}"' EXIT

python3 - "${REGISTRY}" "${TEST_DIR}/registry.json" <<'PY'
import json
import sys

source = sys.argv[1]
target = sys.argv[2]

with open(source, "r", encoding="utf-8") as file:
    registry = json.load(file)

components = registry.get("components", [])

if not components:
    raise SystemExit("No components found in registry")

with open(target, "w", encoding="utf-8") as file:
    json.dump({"components": components}, file)
PY

FIRST_COMPONENT="$(
    python3 - "${REGISTRY}" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as file:
    registry = json.load(file)

components = registry.get("components", [])

if not components:
    raise SystemExit(1)

print(components[0]["id"])
PY
)"

SECOND_COMPONENT="$(
    python3 - "${REGISTRY}" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as file:
    registry = json.load(file)

components = registry.get("components", [])

if len(components) < 2:
    raise SystemExit(1)

print(components[1]["id"])
PY
)"

cat > "${TEST_DIR}/composition.json" <<EOF
{
  "components": [
    "${FIRST_COMPONENT}",
    "${SECOND_COMPONENT}"
  ]
}
