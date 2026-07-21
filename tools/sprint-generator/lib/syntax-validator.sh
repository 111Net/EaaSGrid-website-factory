#!/usr/bin/env bash

FAILED=0

while read -r file
do
    bash -n "$file" || FAILED=1
done < <(find core tests tools -name "*.sh")


if [[ $FAILED -eq 0 ]]
then
    echo "syntax_validation=PASS"
else
    echo "syntax_validation=FAIL"
    exit 1
fi
