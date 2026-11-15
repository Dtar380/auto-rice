-- ============================================================================
--  COLOR PALLETE IMPORT
-- ============================================================================

local theme_path = os.getenv("HOME") .. "/.local/share/rice/current_theme/hypr/colors.lua"

package.loaded[theme_path] = nil

local ok, raw = pcall(require, theme_path)

local defaults = {
    background     = "2e3440",
    foreground     = "e5e9f0",
    accent         = "81a1c1",
    selection      = "88c0d0",
    text           = "e5e9f0",
    subtext        = "d8dee9",
    black          = "2e3440",
    red            = "bf616a",
    yellow         = "a3be8c",
    green          = "ebcb8b",
    blue           = "5e81ac",
    cyan           = "88c0d0",
    magenta        = "b48ead",
    white          = "e5e9f0",
    bright_black   = "3b4252",
    bright_red     = "bf616a",
    bright_yellow  = "a3be8c",
    bright_green   = "ebcb8b",
    bright_blue    = "5e81ac",
    bright_cyan    = "88c0d0",
    bright_magenta = "b48ead",
    bright_white   = "eceff4",
}

local palette = (ok and type(raw) == "table") and setmetatable(raw, { __index = defaults }) or defaults

local M = {
    raw = palette,
}

-- Format as rgba(RRGGBBAA), defaulting alpha to "ff" (opaque)
function M.rgba(hex, alpha)
    hex = hex:gsub("^#", "") -- strip '#' just in case a theme includes it
    return string.format("rgba(%s%s)", hex, alpha or "ff")
end

-- Format as rgb(RRGGBB) for options that don't take alpha
function M.rgb(hex)
    hex = hex:gsub("^#", "")
    return string.format("rgb(%s)", hex)
end

return M
