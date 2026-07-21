#!/usr/bin/env bash

set -Eeuo pipefail

STATE="${1:-}"
ENVIRONMENT="${2:-}"

echo "=== RECOVERY ENGINE ==="

case "${STATE}" in

FAILED)
    echo "recovery_valid=true"
    echo "recovery_action=ROLLBACK"
    ;;

ROLLED_BACK)
    echo "recovery_valid=true"
    echo "recovery_action=RESUME_READY"
    ;;

RECOVERABLE)
    echo "recovery_valid=true"
    echo "recovery_action=RESUME"
    ;;

COMPLETED)
    echo "recovery_valid=true"
    echo "recovery_action=NO_ACTION"
    ;;

*)
    echo "recovery_valid=false"
    echo "recovery_action=BLOCK"
    exit 1
    ;;

esac

echo "environment=${ENVIRONMENT}"

