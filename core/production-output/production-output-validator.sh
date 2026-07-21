#!/bin/bash

SITE_ID=$1

if [ -z "$SITE_ID" ]; then
 echo "ERROR: Site ID required"
 exit 1
fi


OUTPUT="/data/eaasgrid-website-factory/clients/$SITE_ID/generated-site"


echo "=========================================="
echo "PRODUCTION OUTPUT VALIDATOR"
echo "=========================================="


if [ -f "$OUTPUT/index.html" ]; then

echo "output_valid=true"
echo "deployment_ready=true"

else

echo "output_valid=false"
exit 1

fi
