#!/usr/bin/env bash

set -Eeuo pipefail

STATE="${1:-}"
RECOVERY="${2:-false}"
ENVIRONMENT="${3:-staging}"

echo "=== INTELLIGENCE ENGINE ==="

if [[ -z "$STATE" ]]
then
    echo "intelligence_valid=false"
    echo "reason=missing_state"
    exit 1
fi


case "${STATE}" in

CREATED)
    echo "intelligence_valid=true"
    echo "analysis=INITIALIZATION"
    echo "recommendation=PACKAGE"
    ;;

PACKAGED)
    echo "intelligence_valid=true"
    echo "analysis=READY_FOR_TARGET"
    echo "recommendation=RESOLVE_TARGET"
    ;;

EXECUTED)
    if [[ "${RECOVERY}" == "true" ]]
    then
        echo "intelligence_valid=true"
        echo "analysis=EXECUTION_RECOVERY_REQUIRED"
        echo "recommendation=VERIFY_OR_RECOVER"
    else
        echo "intelligence_valid=true"
        echo "analysis=EXECUTION_ACTIVE"
        echo "recommendation=VERIFY"
    fi
    ;;

VERIFIED)
    echo "intelligence_valid=true"
    echo "analysis=DEPLOYMENT_VERIFIED"
    echo "recommendation=COMPLETE"
    ;;

FAILED)
    echo "intelligence_valid=true"
    echo "analysis=FAILURE_DETECTED"
    echo "recommendation=ROLLBACK"
    ;;

ROLLED_BACK)
    echo "intelligence_valid=true"
    echo "analysis=RECOVERY_AVAILABLE"
    echo "recommendation=RESUME"
    ;;

COMPLETED)
    echo "intelligence_valid=true"
    echo "analysis=SUCCESS"
    echo "recommendation=FINALIZE"
    ;;

*)
    echo "intelligence_valid=false"
    echo "analysis=UNKNOWN_STATE"
    exit 1
    ;;

esac

echo "environment=${ENVIRONMENT}"
