#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

DEPLOYMENT_CONTROLLER="${PROJECT_ROOT}/core/deployment-controller/engine/deployment-controller.sh"

WEBSITE_ID="${1:-}"
ENVIRONMENT="${2:-}"
VERSION="${3:-}"

if [[ -z "${WEBSITE_ID}" ||
      -z "${ENVIRONMENT}" ||
      -z "${VERSION}" ]]; then
    echo "ERROR: Usage: deployment-lifecycle-adapter.sh <website_id> <environment> <version>"
    exit 2
fi

if [[ ! -x "${DEPLOYMENT_CONTROLLER}" ]]; then
    echo "ERROR: Deployment lifecycle controller is not executable"
    exit 1
fi

echo "=== DEPLOYMENT LIFECYCLE ADAPTER ==="
echo "website_id=${WEBSITE_ID}"
echo "environment=${ENVIRONMENT}"
echo "version=${VERSION}"

"${DEPLOYMENT_CONTROLLER}" \
    "${WEBSITE_ID}" \
    "${ENVIRONMENT}" \
    "${VERSION}"

echo "deployment-lifecycle-adapter-complete"
