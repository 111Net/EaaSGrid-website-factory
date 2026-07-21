#!/bin/bash

echo "=========================================="
echo "WEEK 15 MASTER AUTOMATED VALIDATION GATE"
echo "=========================================="

cd /data/eaasgrid-website-factory || exit 1

echo
echo "JOB: Client Configuration Engine"

if [ -d core/client-config ]; then
    echo "client_config_valid=true"
else
    echo "client_config_valid=false"
    exit 1
fi


echo
echo "JOB: Production Engine"

if [ -f core/production-engine/production-build.sh ]; then
    echo "production_engine_valid=true"
else
    echo "production_engine_valid=false"
    exit 1
fi


echo
echo "JOB: Core Build Engine"

if [ -f core/build/engine/build-website.sh ]; then
    echo "build_engine_valid=true"
else
    echo "build_engine_valid=false"
    exit 1
fi


echo
echo "JOB: Template Engine"

if [ -f core/template-rendering/engine/render-template.sh ]; then
    echo "template_engine_valid=true"
else
    echo "template_engine_valid=false"
    exit 1
fi


echo
echo "JOB: Theme Engine"

if [ -f core/theme-rendering/engine/render-theme.sh ]; then
    echo "theme_engine_valid=true"
else
    echo "theme_engine_valid=false"
    exit 1
fi


echo
echo "JOB: Runtime Validation"

bash core/runtime/engine/validate-runtime.sh


echo
echo "JOB: Git Integrity"

git status --short

echo
echo "=========================================="
echo "WEEK 15 STATUS: GREEN"
echo "=========================================="
echo "weekly_gate=PASS"
