#!/usr/bin/zsh

set -euo pipefail

# =============================================================================
#  CONSTANTS & GLOBAL STATE
# =============================================================================
# Screenshot save directory, defaulting to ~/Pictures/screenshots
local SCREENSHOTS_DIR="${XDG_PICTURES_DIR:-$HOME/pictures}/screenshots"

# Runtime state, set by parse_args
local MODE=""
local SAVE=0
local COPY=0

# =============================================================================
#  HELPERS
# =============================================================================
usage() {
    cat <<EOF
Usage: ${0:t} [-s] [-c] {full|region}

  -s   save to the screenshots directory
  -c   copy to clipboard
  -h   show this help

With no flags, the screenshot is copied to the clipboard.
Use -s -c (or -sc) to do both.
EOF
}

# =============================================================================
#  FUNCTION: PARSE ARGUMENTS
# =============================================================================
parse_args() {
    local opt

    while getopts ":sch" opt; do
        case "$opt" in
            s) SAVE=1 ;;
            c) COPY=1 ;;
            h) usage; exit 0 ;;
            *) usage >&2; exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    MODE="${1:-}"

    # Default behaviour: clipboard only
    (( SAVE || COPY )) || COPY=1
}

# =============================================================================
#  FUNCTION: CAPTURE
# =============================================================================
# Takes the screenshot and handles saving and/or copying
capture() {
    local -a grim_args=()

    case "$MODE" in
        full)
            ;;
        region)
            local geom
            geom="$(slurp -d)" || exit 0   # Esc/cancel: quit quietly
            grim_args=(-g "$geom")
            ;;
        *)
            usage >&2
            exit 1
            ;;
    esac

    if (( SAVE )); then
        resolve_screenshots_dir
        mkdir -p "$SCREENSHOTS_DIR"

        local file="$SCREENSHOTS_DIR/$(date +'%Y-%m-%d_%H-%M-%S').png"
        grim "${grim_args[@]}" "$file"

        if (( COPY )); then
            wl-copy --type image/png < "$file"
            notify-send "Screenshot" "Saved and copied: $file"
        else
            notify-send "Screenshot" "Saved: $file"
        fi
    else
        grim "${grim_args[@]}" - | wl-copy --type image/png
        notify-send "Screenshot" "Copied to clipboard"
    fi
}

# =============================================================================
#  MAIN
# =============================================================================
parse_args "$@"
capture
