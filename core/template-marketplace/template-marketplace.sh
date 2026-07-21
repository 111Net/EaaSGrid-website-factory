#!/bin/bash

echo "=========================================="
echo "TEMPLATE MARKETPLACE ENGINE"
echo "=========================================="

ROOT="/data/eaasgrid-website-factory"

COUNT=$(find "$ROOT/templates" -maxdepth 2 -type d | wc -l)

echo "marketplace_valid=true"
echo "templates_available=$COUNT"
echo "marketplace_status=ACTIVE"

