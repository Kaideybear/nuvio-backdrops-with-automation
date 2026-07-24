#!/bin/bash

# ── Parse Arguments ──
# TMDb Language Code:  ./generate.sh 6100 network zh
# MDBList Sorting:     ./generate.sh "username/list" mdblist score

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

# ── Configure Correct Flags For NATIVE Script Processing ──
if [ "$TYPE" == "mdblist" ]; then
    # Native flag MDBList expects
    TARGET_FLAG="--url $IDS_INPUT"
    
    # Standardize type back to "mdblist" so internal data queries don't break
    TYPE_FLAG="--type mdblist"
    
    # Extract the slug name (e.g., best-of-the-1950-s)
    SLUG_NAME=$(echo "$IDS_INPUT" | awk -F'/' '{print $2}')
    
    # Map sort type safely if provided
    if [ -n "$EXTRA_PARAM" ] && [ "$EXTRA_PARAM" != "--skip-logos" ]; then
        EXTRA_FLAGS="--sort $EXTRA_PARAM"
    fi
else
    TARGET_FLAG="--id $IDS_INPUT"
    TYPE_FLAG="--type $TYPE"
    SLUG_NAME=""
    
    if [ -n "$EXTRA_PARAM" ] && [ "$EXTRA_PARAM" != "--skip-logos" ]; then
        EXTRA_FLAGS="--language $EXTRA_PARAM"
    fi
fi

echo "=========================================="
echo "Processing: $IDS_INPUT ($TYPE)"
echo "=========================================="

if [ "$SKIP_LOGOS" = false ]; then
    echo "── 1. Pulling logos..."
    $PY_CMD "$ROOT_DIR/scripts/logo_pull.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS
fi

# Run the python backdrop generators explicitly using native flags
echo ""
echo "── 2. Generating T1 Backdrops..."
$PY_CMD "$ROOT_DIR/scripts/backdrop_T1.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS

echo ""
echo "── 3. Generating T1 Flat Backdrops..."
$PY_CMD "$ROOT_DIR/scripts/backdrop_T1_flat.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS

echo ""
echo "── 4. Generating T2 Backdrops..."
$PY_CMD "$ROOT_DIR/scripts/backdrop_T2.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS

echo ""
echo "── 5. Generating T2 Flat Backdrops..."
$PY_CMD "$ROOT_DIR/scripts/backdrop_T2_flat.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS

# ── POST-PROCESSING: Fix Folder Paths If MDBList Generated Generic Folder Names ──
# If MDBList defaults output names, forcefully relocate them to isolated, readable folders
if [ "$TYPE" == "mdblist" ] && [ -n "$SLUG_NAME" ]; then
    echo ""
    echo "── 🚚 Custom Relocation Engine Activating..."
    
    # Look for generic outputs or 'None' directories and name them appropriately
    for dir in output/*/mdblist output/*/None* output/None-unknown-none; do
        if [ -d "$dir" ]; then
            PARENT_DIR=$(dirname "$dir")
            echo "Moving $dir -> $PARENT_DIR/$SLUG_NAME"
            mkdir -p "$PARENT_DIR/$SLUG_NAME"
            mv "$dir"/* "$PARENT_DIR/$SLUG_NAME/" 2>/dev/null
            rmdir "$dir" 2>/dev/null
        fi
    done
fi

echo "=========================================="
echo "🎯 All tasks completed!"
echo "=========================================="
