#!/bin/bash

SITE_ID=$1

if [ -z "$SITE_ID" ]; then
 echo "ERROR: Site ID required"
 exit 1
fi


ROOT="/data/eaasgrid-website-factory"

PACKAGE="$ROOT/clients/$SITE_ID/deployment-package"

TARGET="$ROOT/clients/$SITE_ID/production"


echo "=========================================="
echo "PRODUCTION DEPLOYMENT ENGINE"
echo "=========================================="


if [ ! -d "$PACKAGE" ]; then
 echo "ERROR: Deployment package missing"
 exit 1
fi


mkdir -p "$TARGET"

cp -r "$PACKAGE"/* "$TARGET"/


echo "deployment_status=SUCCESS"
echo "production_path=$TARGET"

