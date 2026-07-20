#!/usr/bin/env bash
set -Eeuo pipefail

CURRENT_STATE="${1:-}"
NEXT_STATE="${2:-}"

if [[ -z "${CURRENT_STATE}" || -z "${NEXT_STATE}" ]]; then
    echo "ERROR: Usage: deployment-state-machine.sh <current_state> <next_state>"
    exit 1
fi

case "${CURRENT_STATE}:${NEXT_STATE}" in
    CREATED:PACKAGED)
        ;;
    PACKAGED:TARGET_RESOLVED)
        ;;
    TARGET_RESOLVED:EXECUTED)
        ;;
    EXECUTED:VERIFIED)
        ;;
    VERIFIED:HEALTH_CHECKED)
        ;;
    HEALTH_CHECKED:COMPLETED)
        ;;
    CREATED:FAILED|PACKAGED:FAILED|TARGET_RESOLVED:FAILED|EXECUTED:FAILED|VERIFIED:FAILED|HEALTH_CHECKED:FAILED)
        ;;
    FAILED:ROLLBACK)
        ;;
    ROLLBACK:ROLLED_BACK)
        ;;
    *)
        echo "ERROR: Invalid deployment lifecycle transition"
        echo "transition=${CURRENT_STATE}->${NEXT_STATE}"
        exit 1
        ;;
esac

echo "deployment-transition-valid"
echo "from=${CURRENT_STATE}"
echo "to=${NEXT_STATE}"
