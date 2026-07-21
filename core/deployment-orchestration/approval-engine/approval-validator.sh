#!/usr/bin/env bash

set -Eeuo pipefail

STATE="${1:-}"
APPROVAL="${2:-false}"
ENVIRONMENT="${3:-staging}"

echo "=== APPROVAL ENGINE ==="

if [[ -z "$STATE" ]]
then
    echo "approval_valid=false"
    echo "reason=missing_state"
    exit 1
fi

case "${STATE}:${ENVIRONMENT}:${APPROVAL}" in

EXECUTED:staging:false)
    echo "approval_valid=true"
    echo "approval_required=false"
    echo "decision=ALLOW"
    ;;

EXECUTED:production:false)
    echo "approval_valid=true"
    echo "approval_required=true"
    echo "decision=BLOCK"
    ;;

EXECUTED:production:true)
    echo "approval_valid=true"
    echo "approval_required=true"
    echo "decision=ALLOW"
    ;;

FAILED:*:*)
    echo "approval_valid=true"
    echo "approval_required=false"
    echo "decision=RECOVERY"
    ;;

ROLLED_BACK:*:*)
    echo "approval_valid=true"
    echo "approval_required=false"
    echo "decision=RESUME_REVIEW"
    ;;

COMPLETED:*:*)
    echo "approval_valid=true"
    echo "approval_required=false"
    echo "decision=CLOSE"
    ;;

*)
    echo "approval_valid=false"
    echo "decision=UNKNOWN"
    exit 1
    ;;

esac

echo "environment=${ENVIRONMENT}"
