#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

RUNTIME_CONTEXT="${PROJECT_ROOT}/core/runtime/engine/runtime-context.sh"

if [[ -x "${RUNTIME_CONTEXT}" ]]; then
    echo "healthy"
else
    echo "unhealthy"
fi
