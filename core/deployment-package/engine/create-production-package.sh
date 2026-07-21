#!/bin/bash

SITE_ID=$1

if [ -z "$SITE_ID" ]; then
    echo "ERROR: Site ID required"
    exit 1
fi

ROOT="/data/eaasgrid-website-factory"

SOURCE="$ROOT/clients/$SITE_ID/generated-site"
PACKAGE="$ROOT/clients/$SITE_ID/deployment-package"


echo "=========================================="
echo "DEPLOYMENT PACKAGE BUILDER"
echo "=========================================="

echo "site=$SITE_ID"


if [ ! -d "$SOURCE" ]; then
    echo "ERROR: Generated website missing"
    exit 1
fi


mkdir -p "$PACKAGE"

cp -r "$SOURCE"/* "$PACKAGE"/


echo "package_created=true"
echo "package_path=$PACKAGE"
