-- ============================================================================
--  DECORATIONS
-- ============================================================================
local colors = require("lua.utils.colors")

hl.config({
	decoration = {
		rounding = 8,
		rounding_power = 2,

		active_opacity = 0.85,
		inactive_opacity = 0.66,

		shadow = {
			enabled = true,
			range = 16,
			render_power = 4,
			color = colors.rgba(colors.raw.black, "d9"),
		},

		blur = {

			enabled = true,
			size = 4,
			passes = 4,
			noise = 0.05,
			vibrancy = 0.25,
			brightness = 0.9,
			contrast = 1.2,
			special = true,
			new_optimizations = true,
			popups = true,
			ignore_opacity = true,
			xray = false,
		},
	},
})
