#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

deployment_context() {
    local website_id="${1:-}"
    local deployment_id="${2:-}"
    local target_environment="${3:-}"

    [[ -n "${website_id}" ]] || {
        echo "ERROR: website_id is required" >&2
        return 1
    }

    [[ -n "${deployment_id}" ]] || {
        echo "ERROR: deployment_id is required" >&2
        return 1
    }

    [[ -n "${target_environment}" ]] || {
        echo "ERROR: target_environment is required" >&2
        return 1
    }

    cat <<CONTEXT
deployment-context-ready
website_id=${website_id}
deployment_id=${deployment_id}
target_environment=${target_environment}
project_root=${PROJECT_ROOT}
CONTEXT
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    deployment_context "${1:-}" "${2:-}" "${3:-}"
fi
