#!/bin/bash

ARGS_RAW=()
CUSTOM_FOLDER=""
SKIP_LOGOS=false

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
            ARGS_RAW+=("$1")
            shift
            ;;
    esac
done

IDS_INPUT="${ARGS_RAW[0]:-}"
TYPE="${ARGS_RAW[1]:-}"
EXTRA_PARAM="${ARGS_RAW[2]:-}"

CUSTOM_FOLDER=""
SKIP_LOGOS=false

shift 3

while [[ $# -gt 0 ]]; do
    case "$1" in
        --folder)
            if [[ -n "$2" ]]; then
                CUSTOM_FOLDER="$2"
                shift 2
            else
                shift
            fi
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

if [[ "$TYPE" == "curated" || "$TYPE" == "mdblist" ]]; then
    SKIP_LOGOS=true
fi

if [[ -z "$IDS_INPUT" || -z "$TYPE" ]]; then
    echo "Usage:"
    echo "./generate.sh <id/slug> <type> [sort/language] [--folder path]"
    exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY_CMD="python3"

ARGS=()

if [[ "$TYPE" == "mdblist" ]]; then
    ARGS+=(--url "$IDS_INPUT")
    ARGS+=(--type mdblist)

    [[ -n "$EXTRA_PARAM" ]] && ARGS+=(--sort "$EXTRA_PARAM")

else
    ARGS+=(--id "$IDS_INPUT")
    ARGS+=(--type "$TYPE")

    [[ -n "$EXTRA_PARAM" ]] && ARGS+=(--language "$EXTRA_PARAM")
fi

if [[ -n "$CUSTOM_FOLDER" ]]; then
    ARGS+=(--folder "$CUSTOM_FOLDER")
fi

echo "=========================================="
echo "Processing: $IDS_INPUT ($TYPE)"
echo "Folder: ${CUSTOM_FOLDER:-auto}"
echo "=========================================="

echo "ARGS:"
printf '%s\n' "${ARGS[@]}"

if [[ "$SKIP_LOGOS" == false ]]; then
    "$PY_CMD" "$ROOT_DIR/scripts/logo_pull.py" "${ARGS[@]}"
fi

"$PY_CMD" "$ROOT_DIR/scripts/backdrop_T1_flat.py" "${ARGS[@]}"

FAILED=0
"$PY_CMD" "$ROOT_DIR/scripts/logo_pull.py" "${ARGS[@]}" || FAILED=1
"$PY_CMD" "$ROOT_DIR/scripts/backdrop_T1_flat.py" "${ARGS[@]}" || FAILED=1
exit $FAILED
