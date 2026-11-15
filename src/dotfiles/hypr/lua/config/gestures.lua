-- ============================================================================
--  GESTURES
-- ============================================================================

hl.config({
	gestures = {
		workspace_swipe_distance = 300,
		workspace_swipe_create_new = true,
	},
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})
