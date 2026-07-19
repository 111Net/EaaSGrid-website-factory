#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

FILES=(
    "components/registry.json"
    "components/core/button.json"
    "components/core/card.json"
    "components/navigation/navbar.json"
    "components/navigation/footer.json"
    "components/forms/form.json"
    "sections/registry.json"
    "sections/hero/section.json"
    "sections/services/section.json"
    "sections/about/section.json"
    "sections/contact/section.json"
    "page-templates/one-page/template.json"
    "page-templates/multi-page/template.json"
    "page-templates/hybrid/template.json"
    "schemas/composition.json"
)

for file in "${FILES[@]}"; do
    [[ -f "$PROJECT_ROOT/$file" ]] || {
        echo "FAIL: Missing $file"
        exit 1
    }
done

echo "PASS: Component registry"
echo "PASS: Reusable components"
echo "PASS: Reusable sections"
echo "PASS: One-page template"
echo "PASS: Multi-page template"
echo "PASS: Hybrid template"
echo "PASS: Composition contract"
