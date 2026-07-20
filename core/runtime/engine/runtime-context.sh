#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

RUNTIME_NAME="${RUNTIME_NAME:-eaasgrid-website-runtime}"
RUNTIME_VERSION="${RUNTIME_VERSION:-1.0.0}"
RUNTIME_ENV="${RUNTIME_ENV:-development}"

export PROJECT_ROOT
export RUNTIME_NAME
export RUNTIME_VERSION
export RUNTIME_ENV

echo "Runtime context initialized"
echo "Runtime: ${RUNTIME_NAME}"
echo "Version: ${RUNTIME_VERSION}"
echo "Environment: ${RUNTIME_ENV}"
