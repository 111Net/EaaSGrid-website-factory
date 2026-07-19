#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PROFILES=(
    "auto-mechanic"
    "systems-integrator"
    "personal"
    "trades-services"
)

for profile in "${PROFILES[@]}"; do
    PROFILE_DIR="${PROJECT_ROOT}/profiles/${profile}"

    [[ -f "${PROFILE_DIR}/profile.json" ]] || {
        echo "FAIL: ${profile}/profile.json missing"
        exit 1
    }

    [[ -f "${PROFILE_DIR}/pages.json" ]] || {
        echo "FAIL: ${profile}/pages.json missing"
        exit 1
    }

    [[ -f "${PROFILE_DIR}/sections.json" ]] || {
        echo "FAIL: ${profile}/sections.json missing"
        exit 1
    }

    [[ -f "${PROFILE_DIR}/content-schema.json" ]] || {
        echo "FAIL: ${profile}/content-schema.json missing"
        exit 1
    }
done

echo "PASS: All website type profiles"
echo "PASS: Profile page definitions"
echo "PASS: Profile section definitions"
echo "PASS: Profile content schemas"
