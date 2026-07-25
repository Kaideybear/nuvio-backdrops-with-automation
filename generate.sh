#!/bin/bash

# ── Parse Arguments ──
# Syntax: ./generate.sh [MDBLIST_SLUG] [TYPE] [SORT_OPTION] [CUSTOM_FOLDER_NAME]
# Example: ./generate.sh "rjchignell/best-of-the-1950-s" mdblist score "1950"

IDS_INPUT=$1
TYPE=$2
EXTRA_PARAM=$3
CUSTOM_FOLDER=$4 # Explicitly captures your fourth argument for the folder path!

SKIP_LOGOS=false
if [ "$TYPE" == "curated" ] || [ "$TYPE" == "mdblist" ]; then
    SKIP_LOGOS=true
fi

for arg in "$@"; do
    if [ "$arg" == "--skip-logos" ]; then
        SKIP_LOGOS=true
    fi
done

if [ -z "$IDS_INPUT" ] || [ -z "$TYPE" ]; then
    echo "Usage: $0 <id/slug> <type> [sort/language] [custom_folder] [--skip-logos]"
    exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
PY_CMD="python3"

# ── Dynamic Flag Engine Setup ──
if [ "$TYPE" == "mdblist" ]; then
    TARGET_FLAG="--url $IDS_INPUT"
    
    # If a fourth parameter is specified on the command line, use it!
    # Otherwise, fall back to "mdblist" defaults natively.
    if [ -n "$CUSTOM_FOLDER" ] && [ "$CUSTOM_FOLDER" != "--skip-logos" ]; then
        TYPE_FLAG="--type $CUSTOM_FOLDER"
    else
        TYPE_FLAG="--type mdblist"
    fi

    if [ -n "$EXTRA_PARAM" ] && [ "$EXTRA_PARAM" != "--skip-logos" ]; then
        EXTRA_FLAGS="--sort $EXTRA_PARAM"
    fi
else
    TARGET_FLAG="--id $IDS_INPUT"
    TYPE_FLAG="--type $TYPE"
    if [ -n "$EXTRA_PARAM" ] && [ "$EXTRA_PARAM" != "--skip-logos" ]; then
        EXTRA_FLAGS="--language $EXTRA_PARAM"
    fi
fi

echo "=========================================="
echo "Processing: $IDS_INPUT ($TYPE)"
echo "Target Folder Override Flag: $TYPE_FLAG"
echo "=========================================="

if [ "$SKIP_LOGOS" = false ]; then
    $PY_CMD "$ROOT_DIR/scripts/logo_pull.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS
fi

$PY_CMD "$ROOT_DIR/scripts/backdrop_T1_flat.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS
