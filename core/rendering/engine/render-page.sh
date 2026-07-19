#!/usr/bin/env bash
set -Eeuo pipefail

PAGE="${1:-}"

if [[ -z "${PAGE}" ]]; then
    echo "ERROR: Page is required"
    exit 1
fi

cat <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${PAGE}</title>
</head>
<body data-page="${PAGE}">
</body>
</html>
HTML
