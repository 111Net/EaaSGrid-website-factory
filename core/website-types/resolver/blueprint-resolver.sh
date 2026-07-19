#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
RESOLVER="${PROJECT_ROOT}/core/website-types/resolver/profile-resolver.sh"

WEBSITE_TYPE="${1:-}"

[[ -n "${WEBSITE_TYPE}" ]] || {
    echo "ERROR: Website type is required"
    exit 1
}

PROFILE_PATH="$("${RESOLVER}" "${WEBSITE_TYPE}")"

echo "Website Type: ${WEBSITE_TYPE}"
echo "Profile Path: ${PROFILE_PATH}"

for file in \
    profile.json \
    pages.json \
    sections.json
do
    [[ -f "${PROFILE_PATH}/${file}" ]] || {
        echo "ERROR: Missing ${file}"
        exit 1
    }

    echo "PASS: ${file}"
done

echo "PASS: Website blueprint resolved"
