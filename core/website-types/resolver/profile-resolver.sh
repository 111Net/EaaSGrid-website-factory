#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PROFILE_ROOT="${PROJECT_ROOT}/profiles"

resolve_website_type() {
    local website_type="${1:-}"

    case "${website_type}" in
        auto-mechanic)
            echo "${PROFILE_ROOT}/auto-mechanic"
            ;;

        systems-integrator)
            echo "${PROFILE_ROOT}/systems-integrator"
            ;;

        personal-website|personal)
            echo "${PROFILE_ROOT}/personal"
            ;;

        trades-services)
            echo "${PROFILE_ROOT}/trades-services"
            ;;

        *)
            echo "ERROR: Unsupported website type: ${website_type}" >&2
            return 1
            ;;
    esac
}

validate_website_type() {
    local website_type="${1:-}"
    local profile_path

    profile_path="$(resolve_website_type "${website_type}")"

    [[ -d "${profile_path}" ]] || {
        echo "ERROR: Profile directory missing: ${profile_path}" >&2
        return 1
    }

    [[ -f "${profile_path}/profile.json" ]] || {
        echo "ERROR: profile.json missing" >&2
        return 1
    }

    [[ -f "${profile_path}/pages.json" ]] || {
        echo "ERROR: pages.json missing" >&2
        return 1
    }

    [[ -f "${profile_path}/sections.json" ]] || {
        echo "ERROR: sections.json missing" >&2
        return 1
    }

    echo "${profile_path}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    validate_website_type "${1:-}"
fi
