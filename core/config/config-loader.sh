#!/usr/bin/env bash
set -Eeuo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${CONFIG_DIR}/../paths/path-resolver.sh"

get_config_file() {
    local environment="${1:-development}"

    case "${environment}" in
        development|test|production)
            factory_path "config/environments/${environment}.json"
            ;;
        *)
            echo "ERROR: Unsupported environment: ${environment}" >&2
            return 1
            ;;
    esac
}
