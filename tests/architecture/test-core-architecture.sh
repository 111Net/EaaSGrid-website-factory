#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

REQUIRED_DIRS=(
    "core/website"
    "core/client"
    "core/pages"
    "core/sections"
    "core/components"
    "core/themes"
    "core/navigation"
    "core/content"
    "core/media"
    "core/build"
    "core/validation"
    "core/deployment"
    "profiles"
)

for directory in "${REQUIRED_DIRS[@]}"; do
    if [[ ! -d "${PROJECT_ROOT}/${directory}" ]]; then
        echo "FAIL: Missing directory ${directory}"
        exit 1
    fi
done

REQUIRED_PROFILES=(
    "auto-mechanic"
    "systems-integrator"
    "personal"
    "trades-services"
)

for profile in "${REQUIRED_PROFILES[@]}"; do
    if [[ ! -f "${PROJECT_ROOT}/profiles/${profile}.json" ]]; then
        echo "FAIL: Missing profile ${profile}"
        exit 1
    fi
done

echo "PASS: Core architecture directories"
echo "PASS: Website type profiles"
echo "PASS: Portable architecture contract"
