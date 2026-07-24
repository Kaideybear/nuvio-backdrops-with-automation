#!/bin/bash

# Accepts standard: ./generate.sh "username/slug" mdblist [sort]
IDS_INPUT=$1
TYPE=$2
EXTRA_PARAM=$3 

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
    echo "Usage: $0 <id/slug> <type> [language/sort] [--skip-logos]"
    exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
PY_CMD="python3"

if [ "$TYPE" == "mdblist" ]; then
    TARGET_FLAG="--url $IDS_INPUT"
    TYPE_FLAG="--type mdblist"
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
echo "Processing Native Run: $IDS_INPUT ($TYPE)"
echo "=========================================="

if [ "$SKIP_LOGOS" = false ]; then
    $PY_CMD "$ROOT_DIR/scripts/logo_pull.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS
fi

$PY_CMD "$ROOT_DIR/scripts/backdrop_T1.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS
$PY_CMD "$ROOT_DIR/scripts/backdrop_T1_flat.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS
$PY_CMD "$ROOT_DIR/scripts/backdrop_T2.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS
$PY_CMD "$ROOT_DIR/scripts/backdrop_T2_flat.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS
