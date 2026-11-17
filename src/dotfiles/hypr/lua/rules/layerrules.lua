-- ============================================================================
--  LAYER RULES
-- ============================================================================

-- Global
hl.layer_rule({
	match = {
		namespace = ".*",
	},
	ignore_alpha = 0,
})

-- Quickshell
hl.layer_rule({
	match = {
		namespace = "quickshell:.*",
	},
	blur = true,
	xray = false,
	ignore_alpha = 0.71,
	no_anim = true,
})
hl.layer_rule({
	match = {
		namespace = "quickshell:desktop",
	},
	blur = false,
})

-- Noanim
hl.layer_rule({
	match = {
		namespace = "^(hypruler|selection|hyprpicker|awww-daemon|gtk4-layer-shell)$",
	},
	no_anim = true,
})

-- Waybar
hl.layer_rule({
    match = {
        namespace = "waybar",
    },
    blur = true,
    ignore_alpha = 0.9,
})
