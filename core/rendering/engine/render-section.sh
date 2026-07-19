#!/usr/bin/env bash
set -Eeuo pipefail

SECTION="${1:-}"

if [[ -z "${SECTION}" ]]; then
    echo "ERROR: Section is required"
    exit 1
fi

cat <<HTML
<section data-section="${SECTION}">
  <!-- Section: ${SECTION} -->
</section>
HTML
