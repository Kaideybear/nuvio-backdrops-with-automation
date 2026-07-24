#!/bin/bash

# Usage: ./generate.sh "username/slug" <target_folder_name> [sort_option]
# Example: ./generate.sh "rjchignell/best-of-the-1950-s" 1950 score

IDS_INPUT=$1
FOLDER_NAME=$2 # This will now dictate your exact output folder
EXTRA_PARAM=$3 

SKIP_LOGOS=true # MDBList doesn't natively pull logos cleanly, keep true

if [ -z "$IDS_INPUT" ] || [ -z "$FOLDER_NAME" ]; then
    echo "Usage: $0 <mdblist-slug> <desired-folder-name> [sort-option]"
    exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
PY_CMD="python3"

# ── Force Python to Build Directly into your Target Folder Name ──
TARGET_FLAG="--url $IDS_INPUT"
TYPE_FLAG="--type $FOLDER_NAME" # Overrides Python's "None-unknown-none" default

EXTRA_FLAGS=""
if [ -n "$EXTRA_PARAM" ] && [ "$EXTRA_PARAM" != "--skip-logos" ]; then
    EXTRA_FLAGS="--sort $EXTRA_PARAM"
fi

echo "=========================================="
echo "Processing Run: $IDS_INPUT"
echo "Target Folder: output/$FOLDER_NAME"
echo "=========================================="

# Run scripts using your hardcoded folder path variables
$PY_CMD "$ROOT_DIR/scripts/backdrop_T1.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS
$PY_CMD "$ROOT_DIR/scripts/backdrop_T1_flat.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS
$PY_CMD "$ROOT_DIR/scripts/backdrop_T2.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS
$PY_CMD "$ROOT_DIR/scripts/backdrop_T2_flat.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS
