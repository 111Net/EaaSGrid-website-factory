#!/usr/bin/env bash
set -Eeuo pipefail

get_project_root() {
    cd "$(dirname "${BASH_SOURCE[0]}")/../.." >/dev/null 2>&1
    pwd
}

PROJECT_ROOT="$(get_project_root)"
export PROJECT_ROOT
