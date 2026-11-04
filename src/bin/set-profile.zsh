#!/usr/bin/zsh

set -euo pipefail

# =============================================================================
#  CONSTANTS & GLOBAL STATE
# =============================================================================
local IMAGE_PATH=""
local FORCE_CROP=0
local USER_NAME="${USER}"
local DEST_DIR="/var/lib/AccountsService/icons"
local DEST_FILE="${DEST_DIR}/${USER_NAME}"

# =============================================================================
#  HELPERS
# =============================================================================
usage() {
    cat <<EOF
Usage: ${0:t} [-f] <image_path>

  -f   force square crop using ImageMagick (convert) if available
  -h   show this help

Updates the user profile picture for SDDM and AccountsService.
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
#  FUNCTION: PROCESS & UPDATE PROFILE
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

    echo "Updating profile picture for user '${USER_NAME}'..."

    # Ensure target directory exists and copy image
    sudo mkdir -p "$DEST_DIR"
    sudo cp "$source_img" "$DEST_FILE"
    sudo chmod 644 "$DEST_FILE"

    # Clean up temporary file if created
    [[ -n "$temp_img" && -f "$temp_img" ]] && rm -f "$temp_img"

    # Notify AccountsService via DBus
    if command -v busctl &> /dev/null; then
        sudo busctl call org.freedesktop.Accounts \
            "/org/freedesktop/Accounts/User$(id -u)" \
            org.freedesktop.Accounts.User \
            SetIconFile s "$DEST_FILE"
    elif command -v dbus-send &> /dev/null; then
        sudo dbus-send --system --print-reply \
            --dest=org.freedesktop.Accounts \
            "/org/freedesktop/Accounts/User$(id -u)" \
            org.freedesktop.Accounts.User.SetIconFile \
            string:"$DEST_FILE"
    fi

    echo "Profile picture successfully updated!"
}

# =============================================================================
#  MAIN
# =============================================================================
parse_args "$@"
update_profile
