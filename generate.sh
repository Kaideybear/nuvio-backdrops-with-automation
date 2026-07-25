#!/bin/bash

POSITIONAL=()
CUSTOM_FOLDER=""
SKIP_LOGOS=true   # default: skip. Only company/network get logos.

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
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

IDS_INPUT="${POSITIONAL[0]:-}"
TYPE="${POSITIONAL[1]:-}"
EXTRA_PARAM="${POSITIONAL[2]:-}"

if [[ "$TYPE" == "company" || "$TYPE" == "network" ]]; then
    SKIP_LOGOS=false
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

STATUS=0
if [[ "$SKIP_LOGOS" == false ]]; then
    "$PY_CMD" "$ROOT_DIR/scripts/logo_pull.py" "${ARGS[@]}" || STATUS=1
fi

"$PY_CMD" "$ROOT_DIR/scripts/backdrop_T1_flat.py" "${ARGS[@]}" || STATUS=1

exit $STATUS
