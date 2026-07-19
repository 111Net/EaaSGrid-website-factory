#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

COMMAND="${1:-}"

case "${COMMAND}" in
    create)
        exec "${PROJECT_ROOT}/core/cli/commands/create.sh" "${@:2}"
        ;;
    validate)
        echo "Validation command reserved for the validation engine."
        ;;
    build)
        echo "Build command reserved for the build engine."
        ;;
    deploy)
        echo "Deploy command reserved for the deployment engine."
        ;;
    status)
        echo "EaaSGrid Website Factory CLI"
        echo "Project Root: ${PROJECT_ROOT}"
        ;;
    "")
        echo "Usage:"
        echo "  factory create"
        echo "  factory validate"
        echo "  factory build"
        echo "  factory deploy"
        echo "  factory status"
        exit 1
        ;;
    *)
        echo "ERROR: Unknown command: ${COMMAND}"
        exit 1
        ;;
esac
