#!/usr/bin/env bash
set -Eeuo pipefail

COMPONENT="${1:-}"

if [[ -z "${COMPONENT}" ]]; then
    echo "ERROR: Component is required"
    exit 1
fi

cat <<HTML
<div data-component="${COMPONENT}">
  <!-- Component: ${COMPONENT} -->
</div>
HTML
