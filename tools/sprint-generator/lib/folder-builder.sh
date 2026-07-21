#!/usr/bin/env bash

set -e

CONFIG="$1"

echo "Creating sprint folders..."

mkdir -p \
core/generated \
tests/sprint-validation \
reports/generated

echo "folders_created=true"

