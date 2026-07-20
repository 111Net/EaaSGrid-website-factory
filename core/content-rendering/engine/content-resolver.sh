#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
PROFILE_ROOT="${PROJECT_ROOT}/profiles"

resolve_content_profile() {
    local website_type="$1"

    case "${website_type}" in
        auto-mechanic)
            echo "${PROFILE_ROOT}/auto-mechanic"
            ;;
        systems-integrator)
            echo "${PROFILE_ROOT}/systems-integrator"
            ;;
        personal|personal-website)
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
