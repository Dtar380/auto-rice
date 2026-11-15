-- ============================================================================
--  ANIMATIONS
-- ============================================================================

hl.config({
	animations = {
		enabled = true,
		workspace_wraparound = true,
	},
})

-- CURVES
hl.curve("instant", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("smooth", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })
hl.curve("easeInExpo", { type = "bezier", points = { { 0.7, 0 }, { 0.84, 0 } } })
hl.curve("easeOutExpo", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("softEase", { type = "bezier", points = { { 0.26, 0.26 }, { 0.15, 1 } } })
hl.curve("mediumEase", { type = "bezier", points = { { 0.4, 0 }, { 0.2, 1 } } })

-- ANIMATIONS
hl.animation({ leaf = "layersIn", enabled = true, speed = 3, bezier = "easeOutExpo", style = "popin" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3, bezier = "easeOutExpo", style = "popin" })
hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "easeOutExpo", style = "popin" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "easeOutExpo", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "easeOutExpo", style = "slide" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "easeOutExpo", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "easeOutExpo", style = "slidevert" })
hl.animation({ leaf = "border", enabled = false, speed = 3, bezier = "smooth" })
hl.animation({ leaf = "fade", enabled = false, speed = 3, bezier = "easeOutExpo" })
hl.animation({ leaf = "fadeLayersIn", enabled = false, speed = 3, bezier = "easeOutExpo" })
hl.animation({ leaf = "fadeLayersOut", enabled = false, speed = 3, bezier = "easeOutExpo" })
hl.animation({ leaf = "monitorAdded", enabled = false })
