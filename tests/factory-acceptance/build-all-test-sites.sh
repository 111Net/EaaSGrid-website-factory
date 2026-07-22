#!/bin/bash

ROOT="/data/eaasgrid-website-factory"

echo "=========================================="
echo "FACTORY PRODUCTION ACCEPTANCE BUILD"
echo "=========================================="

SITES="
factory-restaurant-001
factory-corporate-001
factory-realestate-001
factory-tech-001
"

for SITE in $SITES
do

echo ""
echo "BUILDING: $SITE"

bash core/build/engine/build-website.sh $SITE

if [ $? -eq 0 ]
then
 echo "$SITE=PASS"
else
 echo "$SITE=FAILED"
fi

done


echo ""
echo "factory_production_test=COMPLETE"
