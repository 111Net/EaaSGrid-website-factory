#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

assemble_website_output() {
    local website_root="${1:?Website root is required}"
    local output_root="${2:?Output root is required}"

    mkdir -p \
        "${output_root}/pages" \
        "${output_root}/sections" \
        "${output_root}/components" \
        "${output_root}/assets" \
        "${output_root}/styles" \
        "${output_root}/scripts" \
        "${output_root}/config"

    cat > "${output_root}/output-manifest.json" <<EOF
{
  "factory": "EaaSGrid Website Factory",
  "output_type": "website",
  "source": "${website_root}",
  "output": "${output_root}",
  "status": "assembled",
  "directories": [
    "pages",
    "sections",
    "components",
    "assets",
    "styles",
    "scripts",
    "config"
  ]
}
EOF

    echo "Website output assembled successfully"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    assemble_website_output "$@"
fi
