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

if [ "$TYPE" == "mdblist" ]; then
    TARGET_FLAG="--url \"$IDS_INPUT\""
    TYPE_FLAG="--type mdblist"

    if [ -n "$EXTRA_PARAM" ]; then
        EXTRA_FLAGS="--sort $EXTRA_PARAM"
    fi
else
    TARGET_FLAG="--id $IDS_INPUT"
    TYPE_FLAG="--type $TYPE"

    if [ -n "$EXTRA_PARAM" ]; then
        EXTRA_FLAGS="--language $EXTRA_PARAM"
    fi
fi

if [ -n "$CUSTOM_FOLDER" ]; then
    EXTRA_FLAGS="$EXTRA_FLAGS --folder $CUSTOM_FOLDER"
fi

echo "=========================================="
echo "Processing: $IDS_INPUT ($TYPE)"
echo "Folder: ${CUSTOM_FOLDER:-auto}"
echo "=========================================="

if [ "$SKIP_LOGOS" = false ]; then
    $PY_CMD "$ROOT_DIR/scripts/logo_pull.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS
fi

eval $PY_CMD "$ROOT_DIR/scripts/backdrop_T1_flat.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS
