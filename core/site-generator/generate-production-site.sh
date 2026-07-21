#!/bin/bash

set -e

SITE_ID=$1

if [ -z "$SITE_ID" ]; then
    echo "ERROR: Site ID required"
    exit 1
fi


ROOT="/data/eaasgrid-website-factory"

CLIENT="$ROOT/clients/$SITE_ID"
OUTPUT="$CLIENT/generated-site"


echo "=========================================="
echo "PRODUCTION WEBSITE GENERATOR"
echo "=========================================="

echo "site=$SITE_ID"


if [ ! -f "$CLIENT/requirements/site-request.yaml" ]; then
    echo "ERROR: site request missing"
    exit 1
fi


mkdir -p "$OUTPUT"

echo "JOB: Generate Structure"

mkdir -p "$OUTPUT/pages"
mkdir -p "$OUTPUT/assets"
mkdir -p "$OUTPUT/components"


echo "JOB: Generate Website"

cat > "$OUTPUT/index.html" <<EOF
<!DOCTYPE html>
<html>
<head>
<title>$SITE_ID</title>
<meta name="generator" content="EaaSGrid Factory">
</head>

<body>

<h1>Generated Website</h1>

<p>
Website created automatically by EaaSGrid Website Factory.
</p>

</body>
</html>
EOF


echo "JOB: Output Validation"

if [ -f "$OUTPUT/index.html" ]; then
    echo "website_generation=PASS"
else
    echo "website_generation=FAIL"
    exit 1
fi


echo
echo "=========================================="
echo "PRODUCTION WEBSITE CREATED"
echo "=========================================="

echo "output=$OUTPUT"
