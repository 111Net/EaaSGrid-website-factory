#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

LIFECYCLE_ADAPTER="${PROJECT_ROOT}/core/deployment-orchestration/adapters/deployment-lifecycle-adapter.sh"
RECOVERY_ENGINE="${PROJECT_ROOT}/core/deployment-orchestration/recovery/recover-orchestration.sh"

WEBSITE_ID="${1:-}"
ENVIRONMENT="${2:-}"
VERSION="${3:-}"

if [[ -z "${WEBSITE_ID}" || -z "${ENVIRONMENT}" || -z "${VERSION}" ]]; then
    echo "ERROR: Usage: orchestration-recovery-adapter.sh <website_id> <environment> <version>"
    exit 2
fi

echo "=== ORCHESTRATION RECOVERY ADAPTER ==="

set +e

OUTPUT="$(
    "${LIFECYCLE_ADAPTER}" \
        "${WEBSITE_ID}" \
        "${ENVIRONMENT}" \
        "${VERSION}" 2>&1
)"

STATUS=$?

set -e

printf '%s\n' "${OUTPUT}"

if [[ ${STATUS} -eq 0 ]]; then
    echo "recovery_required=false"
    echo "orchestration-recovery-adapter-complete"
    exit 0
fi

echo "Lifecycle failed."
echo "Starting orchestration recovery..."

LIFECYCLE_AUDIT="${PROJECT_ROOT}/data/deployment-audit/${WEBSITE_ID}-${VERSION}-${ENVIRONMENT}.json"

ORCHESTRATION_AUDIT="${PROJECT_ROOT}/data/deployment-audit/${WEBSITE_ID}-${VERSION}-${ENVIRONMENT}-orchestration.json"

TRANSLATOR="${PROJECT_ROOT}/core/deployment-orchestration/adapters/translate-lifecycle-recovery.sh"

if [[ -x "${TRANSLATOR}" ]]; then

    "${TRANSLATOR}" \
        "${LIFECYCLE_AUDIT}"

else
    echo "WARNING: Lifecycle translator unavailable"
    exit 1
fi


if [[ -x "${RECOVERY_ENGINE}" ]]; then

    "${RECOVERY_ENGINE}" \
        "${ORCHESTRATION_AUDIT}"

else
    echo "WARNING: Recovery engine unavailable"
    exit 1
fi


echo "recovery_required=true"
echo "orchestration-recovery-adapter-complete"

exit 1

echo "recovery_required=true"
echo "orchestration-recovery-adapter-complete"

exit 1#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

LIFECYCLE_ADAPTER="${PROJECT_ROOT}/core/deployment-orchestration/adapters/deployment-lifecycle-adapter.sh"
RECOVERY_ENGINE="${PROJECT_ROOT}/core/deployment-orchestration/recovery/recover-orchestration.sh"

WEBSITE_ID="${1:-}"
ENVIRONMENT="${2:-}"
VERSION="${3:-}"

if [[ -z "${WEBSITE_ID}" || -z "${ENVIRONMENT}" || -z "${VERSION}" ]]; then
    echo "ERROR: Usage: orchestration-recovery-adapter.sh <website_id> <environment> <version>"
    exit 2
fi

echo "=== ORCHESTRATION RECOVERY ADAPTER ==="

set +e

OUTPUT="$(
    "${LIFECYCLE_ADAPTER}" \
        "${WEBSITE_ID}" \
        "${ENVIRONMENT}" \
        "${VERSION}" 2>&1
)"

STATUS=$?

set -e

printf '%s\n' "${OUTPUT}"

if [[ ${STATUS} -eq 0 ]]; then
    echo "recovery_required=false"
    echo "orchestration-recovery-adapter-complete"
    exit 0
fi

echo "Lifecycle failed."
echo "Starting orchestration recovery..."

if [[ -x "${RECOVERY_ENGINE}" ]]; then
    "${RECOVERY_ENGINE}" || true
else
    echo "WARNING: Recovery engine unavailable"
fi

echo "recovery_required=true"
echo "orchestration-recovery-adapter-complete"


exit 1
