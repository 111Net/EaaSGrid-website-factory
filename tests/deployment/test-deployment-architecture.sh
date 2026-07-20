#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "=== DEPLOYMENT ARCHITECTURE TESTS ==="

echo
echo "=== DEPLOYMENT CONTEXT ==="

context="$(
    "${PROJECT_ROOT}/core/deployment/engine/deployment-context.sh" \
        "client-a" \
        "deploy-a" \
        "staging"
)"

echo "${context}" | grep -q "deployment-context-ready"
echo "${context}" | grep -q "website_id=client-a"
echo "${context}" | grep -q "deployment_id=deploy-a"
echo "${context}" | grep -q "target_environment=staging"

echo "PASS: Deployment context"

echo
echo "=== VALID DEPLOYMENT ==="

valid="$(
    "${PROJECT_ROOT}/core/deployment/engine/validate-deployment.sh" \
        "client-a" \
        "deploy-a" \
        "staging"
)"

[[ "${valid}" == "deployment-valid" ]]

echo "PASS: Valid deployment"

echo
echo "=== ENVIRONMENT VALIDATION ==="

for environment in local staging production; do
    "${PROJECT_ROOT}/core/deployment/engine/validate-deployment.sh" \
        "client-a" \
        "deploy-${environment}" \
        "${environment}" \
        >/dev/null

    echo "PASS: ${environment} environment"
done

echo
echo "=== INVALID DEPLOYMENT REJECTION ==="

if "${PROJECT_ROOT}/core/deployment/engine/validate-deployment.sh" \
    "client-a" \
    "deploy-invalid" \
    "invalid" \
    >/dev/null 2>&1; then

    echo "ERROR: Invalid environment was accepted"
    exit 1
fi

echo "PASS: Invalid environment rejection"

echo
echo "PASS: Deployment Architecture"
