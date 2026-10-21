#!/usr/bin/zsh

set -euo pipefail

# =============================================================================
#  CONSTANTS & GLOBAL STATE
# =============================================================================
# Script and repository path resolution
local SCRIPT_DIR="${0:A:h}"
local REPO_ROOT="${SCRIPT_DIR:A:h:h}"

# Path defaults
local RICE_DIR="${RICE_DIR:-$HOME/.local/share/rice}"
local THEMES_DIR="${RICE_DIR}/themes"
local WALLPAPERS_DIR="${RICE_DIR}/wallpapers"

# Fallback to local repo src/assets during testing/development
[[ ! -d "$THEMES_DIR" ]] && THEMES_DIR="$REPO_ROOT/src/assets/themes"
[[ ! -d "$WALLPAPERS_DIR" ]] && WALLPAPERS_DIR="$REPO_ROOT/src/assets/wallpapers"

local CURRENT_THEME_LINK="${RICE_DIR}/current_theme"

# =============================================================================
#  HELPERS
# =============================================================================
# Helper function to capitalize theme names (e.g. "nord_dark" -> "Nord Dark")
capitalize_name() {
    local raw_name="$1"
    # Replace underscores/hyphens with spaces and capitalize each word
    echo "${(C)${raw_name//[-_]/ }}"
}

# =============================================================================
#  FUNCTION: SHOW THEME MENU
# =============================================================================
show_themes_menu() {
    if [[ ! -d "$THEMES_DIR" ]]; then
        notify-send "Rice Error" "Themes directory not found: $THEMES_DIR"
        exit 1
    fi

    local rofi_input=""
    local -A theme_map  # Maps pretty display name back to actual folder name

    # Loop through subdirectories in themes/
    for theme_path in "$THEMES_DIR"/*(/N); do
        local folder_name="${theme_path:t}"
        local display_name
        display_name=$(capitalize_name "$folder_name")

        theme_map[$display_name]="$folder_name"
        local preview_icon=""

        # Detect preview image (preview.png, preview.jpg, or default_wallpaper from metadata)
        if [[ -f "$theme_path/preview.png" ]]; then
            preview_icon="$theme_path/preview.png"
        elif [[ -f "$theme_path/preview.jpg" ]]; then
            preview_icon="$theme_path/preview.jpg"
        elif [[ -f "$theme_path/metadata.json" ]]; then
            local default_wp
            default_wp=$(jq -r '.default_wallpaper // empty' "$theme_path/metadata.json" 2>/dev/null)
            if [[ -n "$default_wp" && -f "$theme_path/wallpapers/$default_wp" ]]; then
                preview_icon="$theme_path/wallpapers/$default_wp"
            fi
        fi

        # Format line for rofi dmenu: Display Name\0icon\x1f/path/to/icon
        if [[ -n "$preview_icon" ]]; then
            rofi_input+="${display_name}\0icon\x1f${preview_icon}\n"
        else
            rofi_input+="${display_name}\n"
        fi
    done

    # Display menu
    local selected_display_name
    selected_display_name=$(printf "%b" "$rofi_input" | rofi -dmenu -p "Theme" -show-icons)

    if [[ -n "$selected_display_name" ]]; then
        local target_folder="${theme_map[$selected_display_name]}"
        notify-send "Rice Menu (Dry Run)" "Selected Theme: $selected_display_name ($target_folder)"
    fi
}

# =============================================================================
#  FUNCTION: SHOW WALLPAPER MENU
# =============================================================================
show_wallpapers_menu() {
    local active_theme_dir=""
    local metadata_file=""

    # Resolve active theme directory
    if [[ -L "$CURRENT_THEME_LINK" || -d "$CURRENT_THEME_LINK" ]]; then
        active_theme_dir="$CURRENT_THEME_LINK"
    else
        # Testing fallback to Nord theme in repo
        active_theme_dir="$THEMES_DIR/nord"
    fi

    metadata_file="$active_theme_dir/metadata.json"

    if [[ ! -f "$metadata_file" ]]; then
        notify-send "Rice Error" "Theme metadata not found at $metadata_file"
        exit 1
    fi

    # Read wallpapers array using zsh array syntax
    local -a wallpaper_list
    wallpaper_list=(${(f)"$(jq -r '.wallpapers[]?' "$metadata_file" 2>/dev/null)"})

    if (( ${#wallpaper_list} == 0 )); then
        notify-send "Rice Error" "No wallpapers defined in metadata.json"
        exit 1
    fi

    local rofi_input=""
    local -A wallpaper_map # Maps invisible key/index back to actual filename

    # Build Rofi input displaying ONLY icons without raw filenames
    local index=1
    for wp in "${wallpaper_list[@]}"; do
        local wp_file=""

        if [[ -f "$active_theme_dir/wallpapers/$wp" ]]; then
            wp_file="$active_theme_dir/wallpapers/$wp"
        elif [[ -f "$WALLPAPERS_DIR/$wp" ]]; then
            wp_file="$WALLPAPERS_DIR/$wp"
        fi

        local label="Wallpaper $index"
        wallpaper_map[$label]="$wp"

        if [[ -n "$wp_file" ]]; then
            # Hides visible text by passing empty display label or subtle index label
            rofi_input+="${label}\0icon\x1f${wp_file}\n"
        else
            rofi_input+="${label}\n"
        fi
        ((index++))
    done

    # Display menu (tip: custom Rofi rasi themes can use -theme-str to show icon-only grid)
    local selected_label
    selected_label=$(printf "%b" "$rofi_input" | rofi -dmenu -p "Wallpaper" -show-icons)

    if [[ -n "$selected_label" ]]; then
        local selected_file="${wallpaper_map[$selected_label]}"
        notify-send "Rice Menu (Dry Run)" "Selected Wallpaper File: $selected_file"
    fi
}

# =============================================================================
#  MAIN
# =============================================================================
case "${1:-}" in
    themes)
        show_themes_menu
        ;;
    wallpapers)
        show_wallpapers_menu
        ;;
    *)
        echo "Usage: rice-menu {themes|wallpapers}"
        exit 1
        ;;
esac
