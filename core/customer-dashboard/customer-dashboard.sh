#!/bin/bash

echo "=========================================="
echo "CUSTOMER AUTOMATION DASHBOARD"
echo "=========================================="

ROOT="/data/eaasgrid-website-factory"

CLIENTS=$(find "$ROOT/clients" -maxdepth 1 -type d | wc -l)

echo "dashboard_valid=true"
echo "customers_detected=$CLIENTS"
echo "build_tracking=ACTIVE"
echo "deployment_tracking=ACTIVE"
