#!/usr/bin/env bash
set -Eeuo pipefail

TEMPLATE_FILE="${1:-}"
OUTPUT_FILE="${2:-}"

if [[ -z "${TEMPLATE_FILE}" || -z "${OUTPUT_FILE}" ]]; then
    echo "Usage: render-template.sh <template-file> <output-file>"
    exit 1
fi

if [[ ! -f "${TEMPLATE_FILE}" ]]; then
    echo "ERROR: Template file not found: ${TEMPLATE_FILE}"
    exit 1
fi

mkdir -p "$(dirname "${OUTPUT_FILE}")"

cp "${TEMPLATE_FILE}" "${OUTPUT_FILE}"

echo "Template rendered successfully"
echo "Source: ${TEMPLATE_FILE}"
echo "Output: ${OUTPUT_FILE}"
