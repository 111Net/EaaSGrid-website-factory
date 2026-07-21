
#!/bin/bash

echo "=========================================="
echo "WEEK 17 MASTER AUTOMATED VALIDATION GATE"
echo "=========================================="


echo
echo "JOB: Deployment Package Engine"

test -f core/deployment-package/engine/create-production-package.sh \
&& echo "deployment_package_engine=PASS" \
|| exit 1


echo
echo "JOB: Production Deployment Engine"

test -f core/production-deployment/deploy-production-site.sh \
&& echo "production_deployment_engine=PASS" \
|| exit 1


echo
echo "JOB: Release Validator"

test -f core/deployment-release/release-validator.sh \
&& echo "release_validator=PASS" \
|| exit 1


echo
echo "JOB: Git Integrity"

git status


echo
echo "=========================================="
echo "WEEK 17 STATUS: GREEN"
echo "=========================================="

echo "weekly_gate=PASS"

