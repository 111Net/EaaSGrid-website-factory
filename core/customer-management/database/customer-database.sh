#!/bin/bash

ROOT="/data/eaasgrid-website-factory"

CUSTOMER_ROOT="$ROOT/clients"

echo "=========================================="
echo "CUSTOMER DATABASE ENGINE"
echo "=========================================="

COUNT=$(find "$CUSTOMER_ROOT" -maxdepth 1 -type d | wc -l)

echo "customer_database=true"
echo "customers_detected=$((COUNT-1))"
echo "database_status=ACTIVE"
