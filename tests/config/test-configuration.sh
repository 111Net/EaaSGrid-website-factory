#!/usr/bin/env bash
set -Eeuo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "${TEST_ROOT}/core/config/config-loader.sh"
source "${TEST_ROOT}/core/config/config-validator.sh"

CONFIG_FILE="$(get_config_file development)"

if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "FAIL: Configuration file missing"
    exit 1
fi

RESULT="$(validate_config_file "${CONFIG_FILE}")"

if [[ "${RESULT}" != "VALID" ]]; then
    echo "FAIL: Configuration validation failed"
    exit 1
fi

echo "PASS: Configuration loader"
echo "PASS: Configuration validator"
