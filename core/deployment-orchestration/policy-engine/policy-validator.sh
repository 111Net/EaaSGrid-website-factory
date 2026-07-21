#!/usr/bin/env bash

set -Eeuo pipefail

ENVIRONMENT="${1:-}"
ACTION="${2:-}"

if [[ -z "${ENVIRONMENT}" || -z "${ACTION}" ]]; then
    echo "ERROR: policy requires ENVIRONMENT ACTION"
    exit 1
fi

echo "=== POLICY VALIDATOR ==="

case "${ENVIRONMENT}:${ACTION}" in

staging:deploy)
    echo "policy_valid=true"
    echo "deployment_allowed=true"
    ;;

staging:rollback)
    echo "policy_valid=true"
    echo "rollback_allowed=true"
    ;;

production:deploy)
    echo "policy_valid=true"
    echo "approval_required=true"
    ;;

production:rollback)
    echo "policy_valid=true"
    echo "rollback_allowed=true"
    ;;

*)
    echo "policy_valid=false"
    echo "action_blocked=true"
    exit 1
    ;;

esac
