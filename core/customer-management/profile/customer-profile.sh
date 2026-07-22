#!/bin/bash

CLIENT=$1

echo "=========================================="
echo "CUSTOMER PROFILE ENGINE"
echo "=========================================="

if [ -z "$CLIENT" ]
then
echo "ERROR: customer required"
exit 1
fi

if [ -d "/data/eaasgrid-website-factory/clients/$CLIENT" ]
then

echo "profile_valid=true"
echo "customer=$CLIENT"
echo "profile_status=ACTIVE"

else

echo "profile_valid=false"

fi

