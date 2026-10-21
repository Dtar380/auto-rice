#!/usr/bin/zsh

set -euo pipefail

# =============================================================================
#  CONSTANTS & GLOBAL STATE
# =============================================================================
# Script and repo path
local SCRIPT_DIR="${0:A:h}"
local REPO_ROOT="${SCRIPT_DIR:A:h:h}"

# Path defaults
local RICE_DIR="${RICE_DIR:-$HOME/.local/share/rice}"
local THEMES_DIR="${RICE_DIR}/themes"
local WALLPAPERS_DIR="${RICE_DIR}/wallpapers"

# Development fallback to local repo assets if runtime dir is missing/empty
[[ ! -d "$THEMES_DIR" ]] && THEMES_DIR="$REPO_ROOT/src/assets/themes"
[[ ! -d "$WALLPAPERS_DIR" ]] && WALLPAPERS_DIR="$REPO_ROOT/src/assets/wallpapers"

local CURRENT_THEME_LINK="${RICE_DIR}/current_theme"
local SDDM_ACTIVE_DIR="/usr/share/sddm/themes/rice-active"

# =============================================================================
#  CORE SWITCH LOGIC
# =============================================================================
apply_theme() {
    local theme_dir="$1"
    local metadata_file="$theme_dir/metadata.json"

    if [[ ! -f "$metadata_file" ]]; then
        notify-send "Rice Error" "Missing metadata.json in $theme_dir"
        exit 1
    fi

    # 1. Update session theme symlink
    ln -sfn "$theme_dir" "$CURRENT_THEME_LINK"

    # 2. Compile app configurations if compiler script exists
    local compiler_script="$REPO_ROOT/tools/rice-compiler.py"
    if [[ -f "$compiler_script" ]]; then
        python3 "$compiler_script" "$theme_dir" || true
    fi

    # 3. Reload active applications (Waybar, Mako, etc.)
    if pgrep -x waybar >/dev/null; then
        pkill -USR2 waybar || true
    fi
    if pgrep -x mako >/dev/null; then
        makoctl reload || true
    fi

    # 4. Sync theme SDDM template files if theme provides an sddm/ folder
    if [[ -d "$theme_dir/sddm" ]]; then
        sudo mkdir -p "$SDDM_ACTIVE_DIR"
        sudo cp -r "$theme_dir/sddm/"* "$SDDM_ACTIVE_DIR/" 2>/dev/null || true

        sudo mkdir -p /etc/sddm.conf.d
        echo -e "[Theme]\nCurrent=rice-active" | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null
    fi

    # 5. Extract default wallpaper and apply via wallpaper-switcher
    local default_wp_name
    default_wp_name=$(jq -r '.default_wallpaper // empty' "$metadata_file" 2>/dev/null)

    if [[ -n "$default_wp_name" ]]; then
        local default_wp_file=""
        if [[ -f "$theme_dir/wallpapers/$default_wp_name" ]]; then
            default_wp_file="$theme_dir/wallpapers/$default_wp_name"
        elif [[ -f "$WALLPAPERS_DIR/$default_wp_name" ]]; then
            default_wp_file="$WALLPAPERS_DIR/$default_wp_name"
        fi

        if [[ -f "$default_wp_file" ]]; then
            "$SCRIPT_DIR/wallpaper-switcher.zsh" "$default_wp_file"
        fi
    fi

    local theme_name="${theme_dir:t}"
    notify-send "Rice" "Switched active theme to: ${(C)theme_name}"
}

# =============================================================================
#  MAIN EXECUTION & GUARDS
# =============================================================================
local target_theme_input="${1:-}"

if [[ -z "$target_theme_input" ]]; then
    echo "Usage: theme-switcher <theme_name_or_path>"
    exit 1
fi

# Resolve full target directory
local theme_dir=""
if [[ -d "$target_theme_input" ]]; then
    theme_dir="$target_theme_input"
elif [[ -d "$THEMES_DIR/$target_theme_input" ]]; then
    theme_dir="$THEMES_DIR/$target_theme_input"
else
    notify-send "Rice Error" "Theme not found: $target_theme_input"
    exit 1
fi

# Smart Guard: Skip if already active
if [[ -L "$CURRENT_THEME_LINK" ]]; then
    local current_target
    current_target=$(readlink -f "$CURRENT_THEME_LINK")
    if [[ "$current_target" == "$(readlink -f "$theme_dir")" ]]; then
        notify-send "Rice" "Theme '${theme_dir:t}' is already active."
        exit 0
    fi
fi

mkdir -p "$RICE_DIR"
apply_theme "$theme_dir"
