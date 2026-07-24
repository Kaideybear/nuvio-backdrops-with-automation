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

# ── Determine Python Flags ──
if [ "$TYPE" == "mdblist" ]; then
    TARGET_FLAG="--url $IDS_INPUT"
    
    # Extract the list name (e.g., best-of-the-1950-s) and force it as the Type 
    # so the Python script builds an isolated directory automatically!
    SLUG_TYPE=$(echo "$IDS_INPUT" | awk -F'/' '{print $2}')
    TYPE_FLAG="--type $SLUG_TYPE"
    
    if [ -n "$EXTRA_PARAM" ] && [ "$EXTRA_PARAM" != "--skip-logos" ]; then
        EXTRA_FLAGS="--sort $EXTRA_PARAM"
    fi
else
    TARGET_FLAG="--id $IDS_INPUT"
    
    if [ -n "$EXTRA_PARAM" ] && [ "$EXTRA_PARAM" != "--skip-logos" ]; then
        # If language code is passed, mutate the type flag so folders split (e.g. network_zh)
        TYPE_FLAG="--type ${TYPE}_${EXTRA_PARAM}"
        EXTRA_FLAGS="--language $EXTRA_PARAM"
    else
        TYPE_FLAG="--type $TYPE"
    fi
fi

# ── Safe Check for Mixed IDs ──
if [[ "$IDS_INPUT" == *"-"* ]] && [[ "$IDS_INPUT" != *"-movies"* ]] && [[ "$IDS_INPUT" != *"-tv"* ]] && [[ "$IDS_INPUT" != *"/"* ]]; then
    echo "── 🔀 Mixed IDs detected: $IDS_INPUT"
    CLEAN_IDS=$(echo "$IDS_INPUT" | tr '-' ' ')
    
    if [ "$SKIP_LOGOS" = false ]; then
        echo "── 1. Pulling logos for mixed sources..."
        for ID in $CLEAN_IDS; do
            $PY_CMD "$ROOT_DIR/scripts/logo_pull.py" --id "$ID" $TYPE_FLAG $EXTRA_FLAGS
        done
    fi

    $PY_CMD "$ROOT_DIR/scripts/backdrop_T1.py" --id $CLEAN_IDS $TYPE_FLAG $EXTRA_FLAGS
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T1_flat.py" --id $CLEAN_IDS $TYPE_FLAG $EXTRA_FLAGS
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T2.py" --id $CLEAN_IDS $TYPE_FLAG $EXTRA_FLAGS
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T2_flat.py" --id $CLEAN_IDS $TYPE_FLAG $EXTRA_FLAGS

else
    echo "=========================================="
    echo "Processing: $IDS_INPUT ($TYPE) | Target Folder: $SLUG_TYPE"
    echo "=========================================="

    if [ "$SKIP_LOGOS" = false ]; then
        echo "── 1. Pulling logos..."
        $PY_CMD "$ROOT_DIR/scripts/logo_pull.py" $TARGET_FLAG $TYPE_FLAG $EXTRA_FLAGS
    fi

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
fi

echo "=========================================="
echo "🎯 All tasks completed!"
echo "=========================================="
