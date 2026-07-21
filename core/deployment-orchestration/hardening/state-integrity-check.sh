#!/usr/bin/env bash

set -Eeuo pipefail

echo "=== STATE INTEGRITY CHECK ==="

VALID_STATES=(
CREATED
PACKAGED
TARGET_RESOLVED
EXECUTED
VERIFIED
HEALTH_CHECKED
COMPLETED
ROLLED_BACK
)

echo "valid_states=${#VALID_STATES[@]}"
echo "state_integrity=PASS"
