#!/usr/bin/zsh

set -euo pipefail

# =============================================================================
#  CONSTANTS & GLOBAL STATE
# =============================================================================
# Path defaults
local RICE_DIR="${RICE_DIR:-$HOME/.local/share/rice}"
local CURRENT_WP_LINK="${RICE_DIR}/current_wallpaper"
local SDDM_ACTIVE_DIR="/usr/share/sddm/themes/rice-active"

# Argument parsing
local target_wp="${1:-}"

# =============================================================================
#  MAIN EXECUTION
# =============================================================================
# Check if wallpaper was passed and if the file exists
if [[ -z "$target_wp" || ! -f "$target_wp" ]]; then
    notify-send "Rice Error" "Invalid or missing wallpaper file: $target_wp"
    exit 1
fi

# =============================================================================
#  SMART GUARD: SKIP IF ALREADY ACTIVE
# =============================================================================
if [[ -L "$CURRENT_WP_LINK" ]]; then
    local current_wp_target
    current_wp_target=$(readlink -f "$CURRENT_WP_LINK")
    if [[ "$current_wp_target" == "$(readlink -f "$target_wp")" ]]; then
        notify-send "Rice" "Wallpaper is already active."
        exit 0
    fi
fi

# 1. Update session persistent symlink
ln -sf "$target_wp" "$CURRENT_WP_LINK"

# 2. Ensure awww-daemon is running and apply live wallpaper
if ! pgrep -x awww-daemon >/dev/null 2>&1; then
    awww-daemon >/dev/null 2>&1 &
    sleep 0.2
fi

awww img "$target_wp" --transition-type grow --transition-fps 60 >/dev/null 2>&1

# 3. Sync to SDDM active slot if it exists
if [[ -d "$SDDM_ACTIVE_DIR" ]]; then
    # Copies active wallpaper to SDDM background image
    sudo cp "$target_wp" "${SDDM_ACTIVE_DIR}/background.png" 2>/dev/null || true
fi

notify-send "Rice" "Wallpaper updated!" -i "$target_wp"
