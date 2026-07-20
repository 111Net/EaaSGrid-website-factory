#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)}"
THEME_ROOT="${PROJECT_ROOT}/themes"

resolve_theme() {
    local theme="$1"

    case "${theme}" in
        default|modern|professional|minimal|dark|custom)
            echo "${THEME_ROOT}/${theme}/theme.json"
            ;;
        *)
            echo "ERROR: Unsupported theme: ${theme}" >&2
            return 1
            ;;
    esac
}
