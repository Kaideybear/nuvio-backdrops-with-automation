#!/bin/bash

# ── Parse Arguments ──
# Accepts standard: ./generate.sh 6100 network
# Accepts mixed   : ./generate.sh 6100-2076 network
# Accepts skip    : ./generate.sh 6100-2076 network --skip-logos

IDS_INPUT=$1
TYPE=$2

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
    echo "Usage: $0 <id or id-id> <type> [--skip-logos]"
    exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY_CMD="python3"

# ── Check for Mixed IDs (Contains a hyphen) ──
if [[ "$IDS_INPUT" == *"-"* ]] && [[ "$IDS_INPUT" != *"-movies"* ]] && [[ "$IDS_INPUT" != *"-tv"* ]]; then
    echo "── 🔀 Mixed IDs detected: $IDS_INPUT"
    
    CLEAN_IDS=$(echo "$IDS_INPUT" | tr '-' ' ')
    
    if [ "$SKIP_LOGOS" = false ]; then
        echo "── 1. Pulling logos for mixed sources..."
        for ID in $CLEAN_IDS; do
            echo "  -> Pulling for ID: $ID"
            $PY_CMD "$ROOT_DIR/scripts/logo_pull.py" --id "$ID" --type "$TYPE"
        done
    else
        echo "── 1. [SKIPPED] Skipping logo pull as requested."
    fi

    echo ""
    echo "── 2. Generating Mixed T1 Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T1.py" --id $CLEAN_IDS --type "$TYPE"

    echo ""
    echo "── 3. Generating Mixed T1 Flat Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T1_flat.py" --id $CLEAN_IDS --type "$TYPE"

    echo ""
    echo "── 4. Generating Mixed T2 Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T2.py" --id $CLEAN_IDS --type "$TYPE"

    echo ""
    echo "── 5. Generating Mixed T2 Flat Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T2_flat.py" --id $CLEAN_IDS --type "$TYPE"

else
    # 1. Grab the first two words directly
    ID="$1"
    TYPE="$2"

    echo "=========================================="
    echo "Processing ID: $ID ($TYPE)"
    echo "=========================================="

    # 2. Logo Pulling
    if [ "$SKIP_LOGOS" = false ]; then
        echo "── 1. Pulling logos..."
        $PY_CMD "$ROOT_DIR/scripts/logo_pull.py" --id "$ID" --type "$TYPE"
    else
        echo "── 1. [SKIPPED] Skipping logo pull as requested."
    fi

    # 3. Run all Python scripts using the specific ID and TYPE
    echo ""
    echo "── 2. Generating T1 Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T1.py" --id "$ID" --type "$TYPE"

    echo ""
    echo "── 3. Generating T1 Flat Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T1_flat.py" --id "$ID" --type "$TYPE"

    echo ""
    echo "── 4. Generating T2 Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T2.py" --id "$ID" --type "$TYPE"

    echo ""
    echo "── 5. Generating T2 Flat Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T2_flat.py" --id "$ID" --type "$TYPE"
fi

echo "=========================================="
echo "🎯 All tasks completed!"
echo "=========================================="