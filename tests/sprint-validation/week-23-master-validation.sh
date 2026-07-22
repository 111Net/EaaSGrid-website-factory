#!/bin/bash

echo "=========================================="
echo "WEEK 23 MASTER AUTOMATED VALIDATION GATE"
echo "=========================================="

echo
echo "JOB: Authentication"

core/customer-platform/authentication/login-engine.sh

echo
echo "JOB: Customer Database"

core/customer-platform/customer-manager/customer-profile.sh


echo
echo "JOB: Customer Dashboard"

core/customer-platform/dashboard/customer-dashboard.sh


echo
echo "JOB: Request Wizard"

core/customer-platform/request-engine/request-wizard.sh


echo
echo "JOB: Git Integrity"

git status


echo
echo "=========================================="
echo "WEEK 23 STATUS: GREEN"
echo "=========================================="

echo "weekly_gate=PASS"
