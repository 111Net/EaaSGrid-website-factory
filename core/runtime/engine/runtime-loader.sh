#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

source "${PROJECT_ROOT}/core/runtime/engine/runtime-context.sh"

"${PROJECT_ROOT}/core/runtime/engine/validate-runtime.sh"

echo "Website runtime loaded successfully"
