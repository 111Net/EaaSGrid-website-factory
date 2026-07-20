#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

validate_deployment() {
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

    case "${target_environment}" in
        local|staging|production)
            ;;
        *)
            echo "ERROR: unsupported deployment environment: ${target_environment}" >&2
            return 1
            ;;
    esac

    echo "deployment-valid"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    validate_deployment "${1:-}" "${2:-}" "${3:-}"
fi
