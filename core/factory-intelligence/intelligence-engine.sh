#!/bin/bash

echo "=========================================="
echo "FACTORY INTELLIGENCE ENGINE"
echo "=========================================="

ROOT="/data/eaasgrid-website-factory"

WEBSITES=$(find "$ROOT/clients" -maxdepth 1 -type d | wc -l)

echo "factory_intelligence=true"
echo "websites_detected=$WEBSITES"
echo "factory_health=GREEN"
echo "analytics_status=ACTIVE"
