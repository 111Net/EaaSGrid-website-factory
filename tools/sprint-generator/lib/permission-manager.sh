#!/usr/bin/env bash

find core tests tools \
-type f \
-name "*.sh" \
-exec chmod +x {} \;

echo "permissions_applied=true"

