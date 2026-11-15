-- ============================================================================
--  AUTOSTART
-- ============================================================================

hl.on("hyprland.start", function()
    hl.exec_cmd("awww-daemon")
-- TODO: Add start processes
end)

hl.on("hyprland.shutdown", function()
-- TODO: Add kill processes
end)
