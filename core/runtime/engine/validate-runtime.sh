#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

[[ -d "${PROJECT_ROOT}" ]] || {
    echo "ERROR: Runtime project root does not exist"
    exit 1
}

[[ -f "${PROJECT_ROOT}/core/output-assembly/engine/assemble-website-output.sh" ]] || {
    echo "ERROR: Output assembly dependency missing"
    exit 1
}

[[ -d "${PROJECT_ROOT}/schemas/output-assembly" ]] || {
    echo "ERROR: Output assembly schema directory missing"
    exit 1
}

echo "Runtime validation passed"
