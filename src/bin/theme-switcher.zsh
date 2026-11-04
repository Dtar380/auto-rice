#!/usr/bin/zsh

set -euo pipefail

# =============================================================================
#  CONSTANTS & GLOBAL STATE
# =============================================================================
local SCRIPT_DIR="${0:A:h}"
local REPO_ROOT="${SCRIPT_DIR:A:h:h}"

local RICE_DIR="${RICE_DIR:-$HOME/.local/share/rice}"
local THEMES_DIR="${RICE_DIR}/themes"
local WALLPAPERS_DIR="${RICE_DIR}/wallpapers"

# Development fallback to local repo assets if runtime dir is missing/empty
[[ ! -d "$THEMES_DIR" ]] && THEMES_DIR="$REPO_ROOT/src/assets/themes"
[[ ! -d "$WALLPAPERS_DIR" ]] && WALLPAPERS_DIR="$REPO_ROOT/src/assets/wallpapers"

local CURRENT_THEME_LINK="${RICE_DIR}/current_theme"
local SDDM_ACTIVE_DIR="/usr/share/sddm/themes/rice-active"

local TARGET_THEME_INPUT=""
local RESOLVED_THEME_DIR=""

# =============================================================================
#  HELPERS
# =============================================================================
usage() {
    cat <<EOF
Usage: ${0:t} [-h] <theme_name_or_path>

  -h   show this help

Switches the active theme, compiles configurations, reloads applications, and syncs SDDM assets.
EOF
}

log_info()  { echo -e "\033[34m[INFO]\033[0m $1"; }
log_ok()    { echo -e "\033[32m[OK]\033[0m $1"; }
log_warn()  { echo -e "\033[33m[WARN]\033[0m $1"; }

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

    TARGET_THEME_INPUT="$1"

    # Resolve full target directory
    if [[ -d "$TARGET_THEME_INPUT" ]]; then
        RESOLVED_THEME_DIR="$TARGET_THEME_INPUT"
    elif [[ -d "$THEMES_DIR/$TARGET_THEME_INPUT" ]]; then
        RESOLVED_THEME_DIR="$THEMES_DIR/$TARGET_THEME_INPUT"
    else
        notify-send "Rice Error" "Theme not found: $TARGET_THEME_INPUT"
        exit 1
    fi
}

# =============================================================================
#  FUNCTION: RELOAD ACTIVE APPS
# =============================================================================
reload_active_apps() {
    log_info "Reloading active theme-dependent applications..."

    local -A app_reload_cmds=(
        [waybar]="pkill -USR2 waybar"
        [mako]="makoctl reload"
        [eww]="eww reload"
        [yazi]="ya cache clear"
        [hyprland]="hyprctl reload"
    )

    for proc_name in "${(@k)app_reload_cmds}"; do
        if pgrep -x "$proc_name" >/dev/null 2>&1; then
            eval "${app_reload_cmds[$proc_name]}" 2>/dev/null && log_ok "Reloaded $proc_name" || log_warn "Failed to reload $proc_name"
        fi
    done
}

# =============================================================================
#  FUNCTION: APPLY THEME
# =============================================================================
apply_theme() {
    # Smart Guard: Skip if already active
    if [[ -L "$CURRENT_THEME_LINK" ]]; then
        local current_target
        current_target=$(readlink -f "$CURRENT_THEME_LINK")
        if [[ "$current_target" == "$(readlink -f "$RESOLVED_THEME_DIR")" ]]; then
            notify-send "Rice" "Theme '${RESOLVED_THEME_DIR:t}' is already active."
            exit 0
        fi
    fi

    local metadata_file="$RESOLVED_THEME_DIR/metadata.json"
    if [[ ! -f "$metadata_file" ]]; then
        notify-send "Rice Error" "Missing metadata.json in $RESOLVED_THEME_DIR"
        exit 1
    fi

    mkdir -p "$RICE_DIR"

    # 1. Update session theme symlink
    ln -sfn "$RESOLVED_THEME_DIR" "$CURRENT_THEME_LINK"

    # 2. Compile app configurations if compiler script exists
    local compiler_script="$REPO_ROOT/tools/rice-compiler.py"
    if [[ -f "$compiler_script" ]]; then
        python3 "$compiler_script" "$RESOLVED_THEME_DIR" || true
    fi

    # 3. Reload active applications
    reload_active_apps

    # 4. Extract default wallpaper and apply via wallpaper-switcher
    local default_wp_name
    default_wp_name=$(jq -r '.default_wallpaper // empty' "$metadata_file" 2>/dev/null)

    if [[ -n "$default_wp_name" ]]; then
        local default_wp_file=""
        if [[ -f "$RESOLVED_THEME_DIR/wallpapers/$default_wp_name" ]]; then
            default_wp_file="$RESOLVED_THEME_DIR/wallpapers/$default_wp_name"
        elif [[ -f "$WALLPAPERS_DIR/$default_wp_name" ]]; then
            default_wp_file="$WALLPAPERS_DIR/$default_wp_name"
        fi

        if [[ -f "$default_wp_file" ]]; then
            "$SCRIPT_DIR/wallpaper-switcher.zsh" "$default_wp_file"
        fi
    fi

    # 5. Sync theme SDDM template files if theme provides an sddm/ folder
    if [[ -d "$RESOLVED_THEME_DIR/sddm" ]]; then
        mkdir -p "$SDDM_ACTIVE_DIR"
        cp -r "$RESOLVED_THEME_DIR/sddm/"* "$SDDM_ACTIVE_DIR/" 2>/dev/null || true

        # Mirror wallpaper into SDDM directory if it exists
        if [[ -n "$default_wp_name" && -f "$default_wp_file" ]]; then
            cp -L "$default_wp_file" "$SDDM_ACTIVE_DIR/background.png" 2>/dev/null || true
        fi
    fi

    local theme_name="${RESOLVED_THEME_DIR:t}"
    notify-send "Rice" "Switched active theme to: ${(C)theme_name}"
}

# =============================================================================
#  MAIN
# =============================================================================
parse_args "$@"
apply_theme
