#!/usr/bin/env bash

set -Eeuo pipefail

echo "=== GIT VALIDATION ==="

git status --short

echo "git_validation_complete=true"
