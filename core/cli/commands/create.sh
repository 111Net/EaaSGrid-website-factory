#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TEMPLATE="${PROJECT_ROOT}/clients/_template"
CLIENTS_DIR="${PROJECT_ROOT}/clients"

NAME=""
TYPE=""
THEME="default"
STRUCTURE="hybrid"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --name)
            NAME="${2:-}"
            shift 2
            ;;
        --type)
            TYPE="${2:-}"
            shift 2
            ;;
        --theme)
            THEME="${2:-default}"
            shift 2
            ;;
        --structure)
            STRUCTURE="${2:-hybrid}"
            shift 2
            ;;
        *)
            echo "ERROR: Unknown option: $1"
            exit 1
            ;;
    esac
done

[[ -n "${NAME}" ]] || {
    echo "ERROR: --name is required"
    exit 1
}

[[ -n "${TYPE}" ]] || {
    echo "ERROR: --type is required"
    exit 1
}

SLUG="$(printf '%s' "${NAME}" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^a-z0-9]/-/g' \
    | sed 's/-\+/-/g' \
    | sed 's/^-//' \
    | sed 's/-$//')"

CLIENT_DIR="${CLIENTS_DIR}/${SLUG}"

[[ ! -e "${CLIENT_DIR}" ]] || {
    echo "ERROR: Client already exists: ${CLIENT_DIR}"
    exit 1
}

cp -a "${TEMPLATE}" "${CLIENT_DIR}"

cat > "${CLIENT_DIR}/client.json" <<JSON
{
  "client_name": "${NAME}",
  "slug": "${SLUG}",
  "website_type": "${TYPE}",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "development"
}
JSON

cat > "${CLIENT_DIR}/website.json" <<JSON
{
  "website_name": "${NAME}",
  "type": "${TYPE}",
  "theme": "${THEME}",
  "structure": "${STRUCTURE}",
  "navigation": {
    "position": "top",
    "sticky": true
  }
}
JSON

echo
echo "========================================="
echo "EaaSGrid Website Factory"
echo "CLIENT CREATED SUCCESSFULLY"
echo "========================================="
echo
echo "Client:"
echo "${NAME}"
echo
echo "Type:"
echo "${TYPE}"
echo
echo "Theme:"
echo "${THEME}"
echo
echo "Structure:"
echo "${STRUCTURE}"
echo
echo "Location:"
echo "${CLIENT_DIR}"
echo
echo "Status:"
echo "READY FOR GENERATION"
echo "========================================="
