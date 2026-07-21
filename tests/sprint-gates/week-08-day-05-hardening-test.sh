#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

GATE="${PROJECT_ROOT}/core/deployment-orchestration/gates/week-08-day-05-hardening-gate.sh"


echo "=========================================="
echo "WEEK 8 DAY 5 HARDENING TEST"
echo "=========================================="


OUTPUT="$("${GATE}")"

echo "${OUTPUT}"


echo "${OUTPUT}" | grep -q "hardening_gate=PASS"

echo
echo "PASS: Week 8 Day 5 Hardening Gate"
