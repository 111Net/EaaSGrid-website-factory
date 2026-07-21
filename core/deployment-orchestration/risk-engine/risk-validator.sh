#!/usr/bin/env bash

set -Eeuo pipefail

STATE="${1:-}"
ENVIRONMENT="${2:-staging}"

echo "=== RISK ENGINE ==="

if [[ -z "$STATE" ]]
then
    echo "risk_valid=false"
    echo "reason=missing_state"
    exit 1
fi


case "${STATE}:${ENVIRONMENT}" in

COMPLETED:*)
    echo "risk_valid=true"
    echo "risk_level=LOW"
    echo "action=FINALIZE"
    ;;

VERIFIED:*)
    echo "risk_valid=true"
    echo "risk_level=LOW"
    echo "action=COMPLETE"
    ;;

EXECUTED:staging)
    echo "risk_valid=true"
    echo "risk_level=MEDIUM"
    echo "action=MONITOR"
    ;;

EXECUTED:production)
    echo "risk_valid=true"
    echo "risk_level=HIGH"
    echo "action=APPROVAL_REQUIRED"
    ;;

FAILED:*)
    echo "risk_valid=true"
    echo "risk_level=CRITICAL"
    echo "action=ROLLBACK"
    ;;

ROLLED_BACK:*)
    echo "risk_valid=true"
    echo "risk_level=MEDIUM"
    echo "action=RECOVERY_REVIEW"
    ;;

*)
    echo "risk_valid=false"
    echo "risk_level=UNKNOWN"
    exit 1
    ;;

esac

echo "environment=${ENVIRONMENT}"
