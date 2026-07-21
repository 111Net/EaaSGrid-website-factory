

#!/usr/bin/env bash

set -Eeuo pipefail

SPRINT="${1:-}"

if [[ -z "$SPRINT" ]]; then
    echo "ERROR: sprint number required"
    exit 1
fi

CONFIG="config/sprints/sprint-${SPRINT}.yaml"

if [[ ! -f "$CONFIG" ]]; then
    echo "ERROR: missing sprint definition"
    exit 1
fi


echo "=========================================="
echo "SPRINT GENERATOR ENGINE"
echo "=========================================="

echo "sprint=$SPRINT"
echo "definition=$CONFIG"


echo ""
echo "JOB: Folder Generation"
bash tools/sprint-generator/lib/folder-builder.sh "$CONFIG"


echo ""
echo "JOB: Validator Generation"
bash tools/sprint-generator/lib/validator-builder.sh "$CONFIG"


echo ""
echo "JOB: Master Gate Generation"
bash tools/sprint-generator/lib/master-gate-builder.sh "$CONFIG"


echo ""
echo "JOB: Permission Control"
bash tools/sprint-generator/lib/permission-manager.sh


echo ""
echo "JOB: Syntax Validation"
bash tools/sprint-generator/lib/syntax-validator.sh

echo ""
echo "JOB: Report Generation"
bash tools/sprint-generator/lib/report-builder.sh

echo ""
echo "JOB: Git Integrity"
bash tools/sprint-generator/lib/git-validator.sh

echo ""
echo "SPRINT GENERATION COMPLETE"
