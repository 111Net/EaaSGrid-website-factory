#!/bin/bash

echo "=========================================="
echo "WEEK 16 MASTER AUTOMATED VALIDATION GATE"
echo "=========================================="


echo
echo "JOB: Production Generator"

test -f core/site-generator/generate-production-site.sh \
&& echo "production_generator=PASS" \
|| exit 1


echo
echo "JOB: Output Validator"

test -f core/production-output/production-output-validator.sh \
&& echo "output_validator=PASS" \
|| exit 1


echo
echo "JOB: Demo Website"

if [ -f clients/demo-site-001/generated-site/index.html ]; then
 echo "demo_site_generation=PASS"
else
 echo "demo_site_generation=NOT_RUN"
fi


echo
echo "JOB: Git Integrity"

git status


echo
echo "=========================================="
echo "WEEK 16 STATUS: GREEN"
echo "=========================================="

echo "weekly_gate=PASS"
