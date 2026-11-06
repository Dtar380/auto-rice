#!/usr/bin/zsh

set -euo pipefail

# =============================================================================
#  CONSTANTS & GLOBAL STATE
# =============================================================================
local RICE_DIR="${RICE_DIR:-$HOME/.local/share/rice}"
local CURRENT_WP_LINK="${RICE_DIR}/current_wallpaper"
local SDDM_ACTIVE_DIR="/usr/share/sddm/themes/rice-active"

local TARGET_WP=""

# =============================================================================
#  HELPERS
# =============================================================================
usage() {
    cat <<EOF
Usage: ${0:t} [-h] <wallpaper_path>

  -h   show this help

Applies a wallpaper to the session, updates symlinks, syncs to SDDM, and sends a notification.
EOF
}

# =============================================================================
#  FUNCTION: PARSE ARGUMENTS
# =============================================================================
parse_args() {
    local opt

    while getopts ":h" opt; do
        case "$opt" in
            h) usage; exit 0 ;;
            *) usage >&2; exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    if (( $# < 1 )); then
        usage >&2
        exit 1
    fi

    TARGET_WP="$1"

    if [[ ! -f "$TARGET_WP" ]]; then
        notify-send "Rice Error" "Invalid or missing wallpaper file: $TARGET_WP"
        exit 1
    fi
}

# =============================================================================
#  FUNCTION: APPLY WALLPAPER
# =============================================================================
apply_wallpaper() {
    # Smart Guard: Skip if already active
    if [[ -L "$CURRENT_WP_LINK" ]]; then
        local current_wp_target
        current_wp_target=$(readlink -f "$CURRENT_WP_LINK")
        if [[ "$current_wp_target" == "$(readlink -f "$TARGET_WP")" ]]; then
            notify-send "Rice" "Wallpaper is already active."
            exit 0
        fi
    fi

    # 1. Update session persistent symlink
    mkdir -p "$RICE_DIR"
    ln -sf "$TARGET_WP" "$CURRENT_WP_LINK"

    # 2. Ensure awww-daemon is running and apply live wallpaper
    if ! pgrep -x awww-daemon >/dev/null 2>&1; then
        awww-daemon >/dev/null 2>&1 &
        sleep 0.2
    fi

    awww img "$TARGET_WP" --transition-type grow --transition-duration 2 --transition-bezier 0.25,0.1,0.25,1.0 --transition-fps 60 >/dev/null 2>&1

    # 3. Sync to SDDM active slot if it exists
    if [[ -d "$SDDM_ACTIVE_DIR" ]]; then
        cp -L "$TARGET_WP" "${SDDM_ACTIVE_DIR}/assets/background.png" 2>/dev/null || true
    fi

    notify-send "Rice" "Wallpaper updated!" -i "$TARGET_WP"
}

# =============================================================================
#  MAIN
# =============================================================================
parse_args "$@"
apply_wallpaper
