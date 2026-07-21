#!/usr/bin/env bash

set -Eeuo pipefail

STATE="${1:-}"

if [[ -z "${STATE}" ]]; then
    echo "ERROR: state required"
    exit 1
fi


VALID_STATES=(
CREATED
PACKAGED
TARGET_RESOLVED
EXECUTED
VERIFIED
COMPLETED
FAILED
ROLLED_BACK
RECOVERABLE
RESUME_READY
)


for VALID in "${VALID_STATES[@]}"
do
    if [[ "${STATE}" == "${VALID}" ]]
    then
        echo "state_valid=true"
        echo "state=${STATE}"
        exit 0
    fi
done


echo "state_valid=false"
echo "invalid_state=${STATE}"

exit 1
