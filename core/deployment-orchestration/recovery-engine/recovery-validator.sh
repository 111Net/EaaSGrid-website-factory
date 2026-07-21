#!/usr/bin/env bash

set -Eeuo pipefail

STATE="${1:-}"
ENVIRONMENT="${2:-}"

echo "=== RECOVERY ENGINE ==="

case "${STATE}" in

FAILED)
echo "recovery_valid=true"
echo "recovery_action=ROLLBACK"
echo "environment=${ENVIRONMENT}"
;;

ROLLED_BACK)
echo "recovery_valid=true"
echo "recovery_action=RESUME_READY"
echo "environment=${ENVIRONMENT}"
;;

COMPLETED)
echo "recovery_valid=true"
echo "recovery_action=NO_ACTION"
echo "environment=${ENVIRONMENT}"
;;

*)
echo "recovery_valid=false"
echo "recovery_action=UNKNOWN"
exit 1
;;

esac
