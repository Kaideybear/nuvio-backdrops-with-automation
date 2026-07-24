#!/bin/bash

# ── Parse Arguments ──
# Standard TMDb:  ./generate.sh 6100 network
# MDBList Normal: ./generate.sh "rjchignell/best-of-the-1950-s" mdblist
# MDBList Sorted: ./generate.sh "rjchignell/best-of-the-1950-s" mdblist score
# Mixed TMDb:     ./generate.sh 6100-2076 network

IDS_INPUT=$1
TYPE=$2
SORT_OR_LANG=$3

SKIP_LOGOS=false
if [ "$TYPE" == "curated" ]; then
    SKIP_LOGOS=true
fi

for arg in "$@"; do
    if [ "$arg" == "--skip-logos" ]; then
        SKIP_LOGOS=true
    fi
done

if [ -z "$IDS_INPUT" ] || [ -z "$TYPE" ]; then
    echo "Usage: $0 <id/slug> <type> [sort/language] [--skip-logos]"
    exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY_CMD="python3"

# ── Determine Python Flags Based on Type ──
# If it's an MDBList, use --url flag. Otherwise, use --id flag.
if [ "$TYPE" == "mdblist" ]; then
    TARGET_FLAG="--url $IDS_INPUT"
    # If a 3rd parameter is passed for mdblist, treat it as the --sort argument
    if [ -n "$SORT_OR_LANG" ] && [ "$SORT_OR_LANG" != "--skip-logos" ]; then
        EXTRA_FLAGS="--sort $SORT_OR_LANG"
    fi
else
    TARGET_FLAG="--id $IDS_INPUT"
    # If a 3rd parameter is passed for standard lists, treat it as --language
    if [ -n "$SORT_OR_LANG" ] && [ "$SORT_OR_LANG" != "--skip-logos" ]; then
        EXTRA_FLAGS="--language $SORT_OR_LANG"
    fi
fi

# ── Check for Mixed IDs (Must contain a hyphen, but NO forward slashes to protect MDBList slugs) ──
if [[ "$IDS_INPUT" == *"-"* ]] && [[ "$IDS_INPUT" != *"-movies"* ]] && [[ "$IDS_INPUT" != *"-tv"* ]] && [[ "$IDS_INPUT" != *"/"* ]]; then
    echo "── 🔀 Mixed IDs detected: $IDS_INPUT"
    CLEAN_IDS=$(echo "$IDS_INPUT" | tr '-' ' ')
    
    if [ "$SKIP_LOGOS" = false ]; then
        echo "── 1. Pulling logos for mixed sources..."
        for ID in $CLEAN_IDS; do
            $PY_CMD "$ROOT_DIR/scripts/logo_pull.py" --id "$ID" --type "$TYPE" $EXTRA_FLAGS
        done
    fi

    $PY_CMD "$ROOT_DIR/scripts/backdrop_T1.py" --id $CLEAN_IDS --type "$TYPE" $EXTRA_FLAGS
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T1_flat.py" --id $CLEAN_IDS --type "$TYPE" $EXTRA_FLAGS
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T2.py" --id $CLEAN_IDS --type "$TYPE" $EXTRA_FLAGS
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T2_flat.py" --id $CLEAN_IDS --type "$TYPE" $EXTRA_FLAGS

else
    echo "=========================================="
    echo "Processing: $IDS_INPUT ($TYPE)"
    echo "=========================================="

    if [ "$SKIP_LOGOS" = false ]; then
        echo "── 1. Pulling logos..."
        # Logo puller might only take standard IDs, adapt flags if it errors out
        $PY_CMD "$ROOT_DIR/scripts/logo_pull.py" $TARGET_FLAG --type "$TYPE" $EXTRA_FLAGS
    fi

    echo ""
    echo "── 2. Generating T1 Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T1.py" $TARGET_FLAG --type "$TYPE" $EXTRA_FLAGS

    echo ""
    echo "── 3. Generating T1 Flat Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T1_flat.py" $TARGET_FLAG --type "$TYPE" $EXTRA_FLAGS

    echo ""
    echo "── 4. Generating T2 Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T2.py" $TARGET_FLAG --type "$TYPE" $EXTRA_FLAGS

    echo ""
    echo "── 5. Generating T2 Flat Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T2_flat.py" $TARGET_FLAG --type "$TYPE" $EXTRA_FLAGS
fi

echo "=========================================="
echo "🎯 All tasks completed!"
echo "=========================================="
