#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLIENT_ID="day04-test-client"
CLIENT_ROOT="${PROJECT_ROOT}/clients/${CLIENT_ID}"

rm -rf "${CLIENT_ROOT}"

mkdir -p \
    "${CLIENT_ROOT}/pages" \
    "${CLIENT_ROOT}/generated"

cat > "${CLIENT_ROOT}/pages/pages.json" <<'JSON'
{
  "structure": "hybrid",
  "pages": [
    {
      "name": "Home",
      "slug": "home",
      "type": "page",
      "sections": [
        "hero",
        "services",
        "contact"
      ]
    },
    {
      "name": "Solar Solutions",
      "slug": "solar-solutions",
      "type": "page",
      "sections": [
        "hero",
        "services"
      ]
    },
    {
      "name": "Contact Us",
      "slug": "contact-us",
      "type": "page",
      "sections": [
        "contact"
      ]
    }
  ]
}
JSON

"${PROJECT_ROOT}/core/page-structure/engine/build-pages.sh" \
    "${CLIENT_ID}"

[[ -f "${CLIENT_ROOT}/generated/pages/home/page.json" ]]
echo "PASS: Home page generated"

[[ -f "${CLIENT_ROOT}/generated/pages/solar-solutions/page.json" ]]
echo "PASS: Custom page generated"

[[ -f "${CLIENT_ROOT}/generated/pages/contact-us/page.json" ]]
echo "PASS: Custom page slug generated"

grep -q '"name": "Solar Solutions"' \
    "${CLIENT_ROOT}/generated/pages/solar-solutions/page.json"

echo "PASS: Custom page name preserved"

grep -q '"structure": "hybrid"' \
    "${CLIENT_ROOT}/pages/pages.json"

echo "PASS: Hybrid structure"

rm -rf "${CLIENT_ROOT}"

echo
echo "PASS: Page Structure Engine"
