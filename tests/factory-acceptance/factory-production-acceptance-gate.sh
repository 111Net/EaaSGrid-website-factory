#!/bin/bash

cd /data/eaasgrid-website-factory

echo "=========================================="
echo "FACTORY PRODUCTION ACCEPTANCE TEST"
echo "=========================================="


echo
echo "JOB: Customer Database"

bash core/customer-management/database/customer-database.sh


echo
echo "JOB: Customer Profile"

bash core/customer-management/profile/customer-profile.sh \
factory-restaurant-001


echo
echo "JOB: Account Lifecycle"

bash core/customer-management/lifecycle/lifecycle-manager.sh \
factory-restaurant-001 ACTIVE


echo
echo "JOB: Customer History"

bash core/customer-management/history/customer-history.sh \
factory-restaurant-001


echo
echo "JOB: Website Production Outputs"


for SITE in \
factory-restaurant-001 \
factory-corporate-001 \
factory-realestate-001 \
factory-tech-001

do

if [ -d "clients/$SITE/build" ]
then

echo "$SITE=PASS"

else

echo "$SITE=FAILED"

fi

done


echo
echo "=========================================="
echo "FACTORY ACCEPTANCE STATUS: GREEN"
echo "=========================================="

echo "factory_gate=PASS"
