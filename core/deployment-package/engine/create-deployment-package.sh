#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

WEBSITE_ID="${1:-}"
ENVIRONMENT="${2:-}"
VERSION="${3:-}"

if [[ -z "${WEBSITE_ID}" || -z "${ENVIRONMENT}" || -z "${VERSION}" ]]; then
    echo "ERROR: website_id, environment and version are required"
    exit 1
fi

case "${ENVIRONMENT}" in
    local|staging|production)
        ;;
    *)
        echo "ERROR: Invalid deployment environment"
        exit 1
        ;;
esac

PACKAGE_ROOT="${PROJECT_ROOT}/data/deployment-package/packages/${WEBSITE_ID}/${VERSION}"

mkdir -p "${PACKAGE_ROOT}"

cat > "${PACKAGE_ROOT}/deployment-manifest.json" <<EOF
{
  "website_id": "${WEBSITE_ID}",
  "environment": "${ENVIRONMENT}",
  "version": "${VERSION}",
  "package_status": "ready",
  "deployment_status": "pending"
}
EOF

echo "deployment-package-ready"
echo "website_id=${WEBSITE_ID}"
echo "environment=${ENVIRONMENT}"
echo "version=${VERSION}"
echo "package=${PACKAGE_ROOT}"
