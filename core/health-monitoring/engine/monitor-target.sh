#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

TARGET_ID="${1:-}"
TARGET_TYPE="${2:-}"

[[ -n "${TARGET_ID}" ]] || {
    echo "ERROR: Target ID is required"
    exit 1
}

[[ -n "${TARGET_TYPE}" ]] || {
    echo "ERROR: Target type is required"
    exit 1
}

case "${TARGET_TYPE}" in
    runtime)
        STATUS="$("${PROJECT_ROOT}/core/health-monitoring/engine/check-runtime-health.sh")"
        ;;
    environment)
        STATUS="$("${PROJECT_ROOT}/core/health-monitoring/engine/check-environment-health.sh" "${TARGET_ID}")"
        ;;
    preview)
        STATUS="$("${PROJECT_ROOT}/core/health-monitoring/engine/check-preview-health.sh" "${TARGET_ID}")"
        ;;
    *)
        echo "ERROR: Unsupported target type: ${TARGET_TYPE}"
        exit 1
        ;;
esac

"${PROJECT_ROOT}/core/health-monitoring/engine/record-health-check.sh" \
    "${TARGET_ID}" \
    "${TARGET_TYPE}" \
    "${STATUS}"

echo "Health status: ${STATUS}"
