-- ============================================================================
--  DECORATIONS
-- ============================================================================
local colors = require("lua.utils.colors")

hl.config({
	decoration = {
		rounding = 8,
		rounding_power = 2,

		active_opacity = 0.85,
		inactive_opacity = 0.75,

		shadow = {
			enabled = true,
			range = 12,
			render_power = 4,
			color = colors.rgba(colors.raw.black, "80"),
		},

		blur = {
			enabled = true,
			size = 12,
			passes = 4,
			noise = 0.125,
			vibrancy = 0.2,
			brightness = 0.85,
			contrast = 1.3,
			special = true,
			new_optimizations = true,
			popups = true,
			ignore_opacity = true,
			xray = false,
		},
	},
})
