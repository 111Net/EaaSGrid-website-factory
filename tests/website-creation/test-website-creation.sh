#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLIENT_ID="day03-test-client"
CLIENT_ROOT="$PROJECT_ROOT/clients/$CLIENT_ID"

rm -rf "$CLIENT_ROOT"

mkdir -p "$CLIENT_ROOT"

cat > "$CLIENT_ROOT/website.json" <<'JSON'
{
  "website_id": "day03-test-client",
  "website_type": "auto-mechanic"
}
JSON

"$PROJECT_ROOT/core/website-creation/engine/create-website.sh" \
    "$CLIENT_ID"

[[ -f "$CLIENT_ROOT/generated/manifest.json" ]]
echo "PASS: Website manifest generated"

[[ -d "$CLIENT_ROOT/generated/pages" ]]
echo "PASS: Pages directory created"

[[ -d "$CLIENT_ROOT/generated/sections" ]]
echo "PASS: Sections directory created"

[[ -d "$CLIENT_ROOT/generated/assets" ]]
echo "PASS: Assets directory created"

[[ -d "$CLIENT_ROOT/generated/config" ]]
echo "PASS: Configuration directory created"

rm -rf "$CLIENT_ROOT"

echo
echo "PASS: Website Creation Engine"
