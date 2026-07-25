#!/bin/bash

IDS_INPUT=$1
TYPE=$2
EXTRA_PARAM=$3

CUSTOM_FOLDER=""
SKIP_LOGOS=false

shift 3

while [[ $# -gt 0 ]]; do
    case "$1" in
        --folder)
            CUSTOM_FOLDER="$2"
            shift 2
            ;;
        --skip-logos)
            SKIP_LOGOS=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if [ "$TYPE" == "curated" ] || [ "$TYPE" == "mdblist" ]; then
    SKIP_LOGOS=true
fi

if [ -z "$IDS_INPUT" ] || [ -z "$TYPE" ]; then
    echo "Usage:"
    echo "./generate.sh <id/slug> <type> [sort/language] [--folder path] [--skip-logos]"
    exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
PY_CMD="python3"

ARGS=()

if [ "$TYPE" == "mdblist" ]; then
    ARGS+=(--url "$IDS_INPUT")
    ARGS+=(--type mdblist)

    if [ -n "$EXTRA_PARAM" ]; then
        ARGS+=(--sort "$EXTRA_PARAM")
    fi
else
    ARGS+=(--id "$IDS_INPUT")
    ARGS+=(--type "$TYPE")

    if [ -n "$EXTRA_PARAM" ]; then
        ARGS+=(--language "$EXTRA_PARAM")
    fi
fi

if [ -n "$CUSTOM_FOLDER" ]; then
    ARGS+=(--folder "$CUSTOM_FOLDER")
fi

echo "=========================================="
echo "Processing: $IDS_INPUT ($TYPE)"
echo "Folder: ${CUSTOM_FOLDER:-auto}"
echo "=========================================="

if [ "$SKIP_LOGOS" = false ]; then
    $PY_CMD "$ROOT_DIR/scripts/logo_pull.py" "${ARGS[@]}"
fi

$PY_CMD "$ROOT_DIR/scripts/backdrop_T1_flat.py" "${ARGS[@]}"
