-- ============================================================================
--  AUTOSTART
-- ============================================================================

hl.on("hyprland.start", function()
    hl.exec_cmd('awww-daemon & awww img "$HOME/.local/share/rice/current_wallpaper"')
    hl.exec_cmd('hyprsunset')
    hl.exec_cmd('hypridle')
-- TODO: Add start processes
end)

hl.on("hyprland.shutdown", function()
-- TODO: Add kill processes
end)
