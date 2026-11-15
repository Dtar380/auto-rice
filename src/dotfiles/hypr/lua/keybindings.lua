-- ============================================================================
--  KEYBINDINGS
-- ============================================================================

local ws = require("lua.utils.workspaces")

-- *** PROGRAMS ***
local terminal    = "alacritty"
local fileManager = terminal .. " -e zsh -ic 'y; exec zsh'"
local menu        = "rofi -show drun"
local browser     = "zen-browser"
local editor      = "nvim"

-- *** MAIN MOD KEY ***
local mainMod = "SUPER"

-- *** BINDS ***
-- Windows
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Apps
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(editor))

-- Focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Workspaces: SUPER + 1..9,0 focus | SUPER + SHIFT + 1..9,0 move window
for i = 1, math.min(ws.max, 10) do
  local key = tostring(i % 10) -- workspace 10 uses the 0 key
  hl.bind(mainMod .. " + " .. key,         function() ws.focus(i) end)
  hl.bind(mainMod .. " + SHIFT + " .. key, function() ws.move(i) end)
end

-- Relative workspace navigation (clamped to ws.max)
hl.bind(mainMod .. " + mouse_down", function() ws.focus_relative(1) end)
hl.bind(mainMod .. " + mouse_up",   function() ws.focus_relative(-1) end)
hl.bind(mainMod .. " + CTRL + right", function() ws.focus_relative(1) end)
hl.bind(mainMod .. " + CTRL + left",  function() ws.focus_relative(-1) end)
hl.bind(mainMod .. " + CTRL + SHIFT + right", function() ws.move_relative(1) end)
hl.bind(mainMod .. " + CTRL + SHIFT + left",  function() ws.move_relative(-1) end)

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
