#!/bin/bash

ROOT="/data/eaasgrid-website-factory"

echo "=========================================="
echo "FACTORY CUSTOMER ACCEPTANCE TEST SETUP"
echo "=========================================="

create_customer(){

CLIENT=$1
TYPE=$2
TEMPLATE=$3

mkdir -p "$ROOT/clients/$CLIENT/requirements"

cat > "$ROOT/clients/$CLIENT/requirements/site-request.yaml" <<EOF
customer:
  id: $CLIENT
  name: "$CLIENT Test Customer"
  industry: "$TYPE"

website:
  type: $TYPE
  template: $TEMPLATE

pages:
  - home
  - about
  - services
  - contact

features:
  - responsive-design
  - seo
  - contact-form

deployment:
  environment: staging
EOF

echo "$CLIENT created"

}

create_customer \
factory-restaurant-001 \
restaurant \
restaurant-modern

create_customer \
factory-corporate-001 \
corporate \
corporate-modern

create_customer \
factory-realestate-001 \
real-estate \
realestate-premium

create_customer \
factory-tech-001 \
technology \
saas-modern


echo "customer_creation=PASS"
