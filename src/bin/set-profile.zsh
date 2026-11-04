#!/usr/bin/zsh

set -euo pipefail

# =============================================================================
#  CONSTANTS & GLOBAL STATE
# =============================================================================
local IMAGE_PATH=""
local FORCE_CROP=0
local DEST_DIR="$HOME"
local FACE_FILE="${DEST_DIR}/.face"
local FACE_ICON_FILE="${DEST_DIR}/.face.icon"

# =============================================================================
#  HELPERS
# =============================================================================
usage() {
    cat <<EOF
Usage: ${0:t} [-f] <image_path>

  -f   force square crop using ImageMagick (convert) if available
  -h   show this help

Updates the user profile picture by copying/linking to ~/.face and ~/.face.icon.
EOF
}

# =============================================================================
#  FUNCTION: PARSE ARGUMENTS
# =============================================================================
parse_args() {
    local opt

    while getopts ":fh" opt; do
        case "$opt" in
            f) FORCE_CROP=1 ;;
            h) usage; exit 0 ;;
            *) usage >&2; exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    if (( $# < 1 )); then
        usage >&2
        exit 1
    fi

    IMAGE_PATH="$(realpath "$1")"

    if [[ ! -f "$IMAGE_PATH" ]]; then
        echo "Error: Image file '$IMAGE_PATH' does not exist." >&2
        exit 1
    fi
}

# =============================================================================
#  FUNCTION: UPDATE PROFILE
# =============================================================================
update_profile() {
    local source_img="$IMAGE_PATH"
    local temp_img=""

    # Optional auto-crop to 1:1 ratio if ImageMagick is installed and -f is passed
    if (( FORCE_CROP )); then
        if command -v convert &> /dev/null; then
            temp_img="$(mktemp --suffix=.png)"
            convert "$IMAGE_PATH" -gravity center -extent 1:1 "$temp_img"
            source_img="$temp_img"
        else
            echo "Warning: ImageMagick (convert) not found. Skipping auto-crop." >&2
        fi
    fi

    echo "Updating profile picture in home directory..."

    # Copy the processed image directly to ~/.face and ~/.face.icon
    cp "$source_img" "$FACE_FILE"
    cp "$source_img" "$FACE_ICON_FILE"
    chmod 644 "$FACE_FILE" "$FACE_ICON_FILE"

    # Clean up temporary file if created
    [[ -n "$temp_img" && -f "$temp_img" ]] && rm -f "$temp_img"

    echo "Profile picture successfully updated to ~/.face and ~/.face.icon!"
}

# =============================================================================
#  MAIN
# =============================================================================
parse_args "$@"
update_profile
