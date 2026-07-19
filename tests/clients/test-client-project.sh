#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLIENT_ROOT="$PROJECT_ROOT/clients/_template"

for directory in \
  content \
  media \
  pages \
  theme \
  build \
  deployment \
  generated
do
  [[ -d "$CLIENT_ROOT/$directory" ]] || {
    echo "FAIL: Missing client directory $directory"
    exit 1
  }
done

for file in \
  client.json \
  website.json \
  content/content.json \
  pages/pages.json \
  theme/theme.json \
  build/build.json \
  deployment/deployment.json
do
  [[ -f "$CLIENT_ROOT/$file" ]] || {
    echo "FAIL: Missing client file $file"
    exit 1
  }
done

[[ -f "$PROJECT_ROOT/schemas/clients/client-project.schema.json" ]]
[[ -f "$PROJECT_ROOT/schemas/generation/generation-contract.json" ]]

echo "PASS: Client project directories"
echo "PASS: Client identity contract"
echo "PASS: Website configuration contract"
echo "PASS: Content structure"
echo "PASS: Page structure"
echo "PASS: Theme structure"
echo "PASS: Build structure"
echo "PASS: Deployment structure"
echo "PASS: Generation contract"
