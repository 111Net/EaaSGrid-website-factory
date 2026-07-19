#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CLIENT_ID="${1:-}"

[[ -n "$CLIENT_ID" ]] || {
    echo "ERROR: Client ID required"
    exit 1
}

CLIENT_ROOT="$PROJECT_ROOT/clients/$CLIENT_ID"

[[ -d "$CLIENT_ROOT" ]] || {
    echo "ERROR: Client does not exist: $CLIENT_ID"
    exit 1
}

[[ -f "$CLIENT_ROOT/website.json" ]] || {
    echo "ERROR: website.json missing"
    exit 1
}

mkdir -p \
    "$CLIENT_ROOT/generated/pages" \
    "$CLIENT_ROOT/generated/sections" \
    "$CLIENT_ROOT/generated/assets" \
    "$CLIENT_ROOT/generated/config"

cp "$CLIENT_ROOT/website.json" \
   "$CLIENT_ROOT/generated/config/website.json"

cat > "$CLIENT_ROOT/generated/manifest.json" <<EOF
{
  "client_id": "$CLIENT_ID",
  "engine": "EaaSGrid Website Factory",
  "status": "created",
  "generated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

echo "Website created successfully: $CLIENT_ID"
