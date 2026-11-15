-- ============================================================================
--  GENERAL
-- ============================================================================

local colors = require("lua.utils.colors")

hl.config({
    general = {
        layout = "dwindle",
        allow_tearing = true,
        gaps_in = 4,
        gaps_out = 12,
        border_size = 1,
        no_focus_fallback = false,

        snap = {
            enabled = true,
            respect_gaps = true,
        },

        col = {
            active_border = colors.rgba(colors.raw.accent, "d9"),
            inactive_border = colors.rgba(colors.raw.bright_black, "d9"),
        },
    },
})
