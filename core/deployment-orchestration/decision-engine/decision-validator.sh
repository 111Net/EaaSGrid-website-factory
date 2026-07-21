#!/usr/bin/env bash

set -Eeuo pipefail

STATE="${1:-}"
POLICY="${2:-}"
ENVIRONMENT="${3:-}"

if [[ -z "${STATE}" || -z "${POLICY}" || -z "${ENVIRONMENT}" ]]; then
    echo "ERROR: decision requires STATE POLICY ENVIRONMENT"
    exit 1
fi

echo "=== DECISION ENGINE ==="

case "${STATE}:${POLICY}:${ENVIRONMENT}" in

COMPLETED:true:*)
    echo "decision=APPROVE"
    echo "action=COMPLETE"
    ;;

EXECUTED:true:staging)
    echo "decision=APPROVE"
    echo "action=CONTINUE"
    ;;

FAILED:true:*)
    echo "decision=RECOVER"
    echo "action=ROLLBACK"
    ;;

ROLLED_BACK:true:*)
    echo "decision=RESUME"
    echo "action=RESUME_READY"
    ;;

*:false:*)
    echo "decision=BLOCK"
    echo "action=POLICY_DENIED"
    exit 1
    ;;

*)
    echo "decision=BLOCK"
    echo "action=UNKNOWN_STATE"
    exit 1
    ;;

esac
