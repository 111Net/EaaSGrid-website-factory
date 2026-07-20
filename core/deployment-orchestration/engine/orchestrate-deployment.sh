#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

CONTROLLER="${PROJECT_ROOT}/core/deployment-controller/engine/deployment-controller.sh"

WEBSITE_ID="${1:-}"
ENVIRONMENT="${2:-}"
VERSION="${3:-}"

if [[ -z "${WEBSITE_ID}" ||
      -z "${ENVIRONMENT}" ||
      -z "${VERSION}" ]]; then
    echo "ERROR: Usage: orchestrate-deployment.sh <website_id> <environment> <version>"
    exit 2
fi

if [[ ! -x "${CONTROLLER}" ]]; then
    echo "ERROR: Deployment controller unavailable"
    exit 1
fi

DEPLOYMENT_ID="${WEBSITE_ID}-${VERSION}-${ENVIRONMENT}"

echo "=== DEPLOYMENT ORCHESTRATOR ==="
echo "deployment_id=${DEPLOYMENT_ID}"
echo "website_id=${WEBSITE_ID}"
echo "environment=${ENVIRONMENT}"
echo "version=${VERSION}"

echo
echo "ORCHESTRATION: STARTED"

echo
echo "DELEGATING TO DEPLOYMENT CONTROLLER"

"${CONTROLLER}" \
    "${WEBSITE_ID}" \
    "${ENVIRONMENT}" \
    "${VERSION}"

echo
echo "ORCHESTRATION: COMPLETED"
echo "deployment_id=${DEPLOYMENT_ID}"
echo "orchestration_status=complete"
