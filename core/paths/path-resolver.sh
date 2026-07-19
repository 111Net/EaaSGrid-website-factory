#!/usr/bin/env bash
set -Eeuo pipefail

PATH_RESOLVER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${PATH_RESOLVER_DIR}/project-root.sh"

factory_path() {
    local relative_path="${1:-}"

    if [[ -z "${relative_path}" ]]; then
        printf '%s\n' "${PROJECT_ROOT}"
    else
        printf '%s/%s\n' "${PROJECT_ROOT}" "${relative_path}"
    fi
}

export -f factory_path
