#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for theme in default modern professional minimal dark custom; do
  [[ -f "$PROJECT_ROOT/themes/$theme/theme.json" ]] || {
    echo "FAIL: $theme theme missing"
    exit 1
  }
done

[[ -f "$PROJECT_ROOT/themes/registry.json" ]]
[[ -f "$PROJECT_ROOT/themes/theme-system.json" ]]
[[ -f "$PROJECT_ROOT/schemas/themes/theme.schema.json" ]]

echo "PASS: Theme registry"
echo "PASS: Six theme profiles"
echo "PASS: Theme system contract"
echo "PASS: Theme schema"
