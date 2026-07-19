#!/usr/bin/env bash
set -Eeuo pipefail

create_rendering_context() {
    local client_id="${1:-}"
    local build_root="${2:-}"

    if [[ -z "${client_id}" ]]; then
        echo "ERROR: client_id is required" >&2
        return 1
    fi

    if [[ -z "${build_root}" ]]; then
        echo "ERROR: build_root is required" >&2
        return 1
    fi

    cat <<JSON
{
  "client_id": "${client_id}",
  "build_root": "${build_root}",
  "renderer": "generic",
  "status": "initialized"
}
JSON
}
