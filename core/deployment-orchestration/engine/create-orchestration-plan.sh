#!/usr/bin/env bash
set -Eeuo pipefail

REQUEST_FILE="${1:-}"

if [[ -z "${REQUEST_FILE}" ]]; then
    echo "ERROR: Deployment request file is required"
    exit 1
fi

if [[ ! -f "${REQUEST_FILE}" ]]; then
    echo "ERROR: Deployment request file does not exist"
    exit 1
fi

python3 - "${REQUEST_FILE}" <<'PY'
import json
import sys
from pathlib import Path

request_path = Path(sys.argv[1])
request = json.loads(request_path.read_text())

deployment_id = request.get("deployment_id")
stages = request.get("stages")

if not deployment_id:
    raise SystemExit("ERROR: deployment_id is required")

if not isinstance(stages, list) or not stages:
    raise SystemExit("ERROR: stages must be a non-empty list")

stage_map = {}

for stage in stages:
    name = stage.get("name")
    depends_on = stage.get("depends_on", [])

    if not name:
        raise SystemExit("ERROR: stage name is required")

    if name in stage_map:
        raise SystemExit(f"ERROR: duplicate stage: {name}")

    stage_map[name] = set(depends_on)

for name, dependencies in stage_map.items():
    unknown = dependencies - stage_map.keys()

    if unknown:
        raise SystemExit(
            f"ERROR: unknown dependency for {name}: "
            f"{', '.join(sorted(unknown))}"
        )

resolved = []
remaining = {
    name: set(dependencies)
    for name, dependencies in stage_map.items()
}

while remaining:
    ready = sorted(
        name
        for name, dependencies in remaining.items()
        if not dependencies
    )

    if not ready:
        raise SystemExit(
            "ERROR: circular dependency detected"
        )

    resolved.extend(ready)

    for name in ready:
        del remaining[name]

    for dependencies in remaining.values():
        dependencies.difference_update(ready)

plan = {
    "deployment_id": deployment_id,
    "plan_status": "valid",
    "execution_order": resolved,
    "stage_count": len(resolved),
}

output_path = request_path.with_name(
    request_path.stem + "-plan.json"
)

output_path.write_text(
    json.dumps(plan, indent=2) + "\n"
)

print("orchestration-plan-created")
print(f"deployment_id={deployment_id}")
print(f"plan_status={plan['plan_status']}")
print(f"stage_count={plan['stage_count']}")
print(f"execution_order={' -> '.join(resolved)}")
print(f"plan_file={output_path}")
PY
