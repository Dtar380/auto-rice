-- ============================================================================
--  AUTOSTART
-- ============================================================================

hl.on("hyprland.start", function()
    -- needed
    hl.exec_cmd("/usr/lib/xdg-desktop-portal")
    -- hypr tools
    hl.exec_cmd('systemctl --user start hyprpolkitagent.service')
    hl.exec_cmd('hyprsunset')
    hl.exec_cmd('hypridle')
    -- background
    hl.exec_cmd('awww-daemon & awww img "$HOME/.local/share/rice/current_wallpaper"')
    -- wl clipboard
    hl.exec_cmd('wl-paste --type text --watch cliphist store')
    hl.exec_cmd('wl-paste --type image --watch cliphist store')
    -- quickshell
    hl.exec_cmd("qs")
-- TODO: Add start processes
end)

hl.on("hyprland.shutdown", function()
-- TODO: Add kill processes
end)
