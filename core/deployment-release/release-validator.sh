#!/bin/bash

SITE_ID=$1

if [ -z "$SITE_ID" ]; then
 echo "ERROR: Site ID required"
 exit 1
fi


TARGET="/data/eaasgrid-website-factory/clients/$SITE_ID/production"


echo "=========================================="
echo "RELEASE VALIDATION"
echo "=========================================="


if [ -f "$TARGET/index.html" ]; then

echo "release_valid=true"
echo "release_status=APPROVED"

else

echo "release_valid=false"
exit 1

fi

