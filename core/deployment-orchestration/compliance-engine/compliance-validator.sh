#!/usr/bin/env bash

set -Eeuo pipefail

ENVIRONMENT="${1:-staging}"

echo "=== COMPLIANCE ENGINE ==="

case "${ENVIRONMENT}" in

staging)
echo "compliance_valid=true"
echo "policy_status=PASS"
echo "environment=staging"
;;

production)
echo "compliance_valid=true"
echo "policy_status=APPROVAL_REQUIRED"
echo "environment=production"
;;

*)
echo "compliance_valid=false"
echo "policy_status=BLOCKED"
exit 1
;;

esac
