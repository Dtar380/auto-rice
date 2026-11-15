-- ============================================================================
--  WINDOW RULES
-- ============================================================================

-- Repeated match patterns
local floating_classes = "^(blueman-manager|org.pulseaudio.pavucontrol|org.gnome.Calculator|com.saivert.pwvucontrol|qalculate-gtk|org.gnome.Characters|org.gnome.clocks|org.gnome.Tecla|PortProton|clipse.*|float|smile|waypaper|org.kde.kdeconnect.daemon|dev.bragefuglseth.Keypunch.Devel|flameshot|nz.co.mega.megasync|Bitwarden)$"
local small_floating_classes = "^(org.pulseaudio.pavucontrol|com.saivert.pwvucontrol|qalculate-gtk|org.gnome.clocks|clipse.*|waypaper)$"
local large_floating_classes = "^(org.gnome.Geary|io.github.kaii_lb.Overskride|org.gnome.Settings|float)$"
local opaque_classes = "^(zen|firefox-nightly|helium|brave-origin|brave|spotify|vesktop|org.gnome.Snapshot|google-chrome|hayase|mpv|nz.co.mega.megasync|virt-manager|Emulator|scrcpy)$"
local pinned_titles = [[^(MEGAsync|[Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture.*)$]]

-- Xray windows
hl.window_rule({
	match = { class = ".*" },
	opacity = "0.92",
	enabled = true,
})

-- Floating classes
hl.window_rule({
	match = { class = floating_classes },
	float = true,
	center = true,
})

-- Small floating classes
hl.window_rule({
	match = { class = small_floating_classes },
	size = "monitor_w*0.45 monitor_h*0.60",
})

-- Large floating classes
hl.window_rule({
	match = { class = large_floating_classes },
	float = true,
	center = true,
	size = "monitor_w*0.6906 monitor_h*0.6917",
})

-- Pinned titles
hl.window_rule({
	match = { title = pinned_titles },
	no_blur = true,
	border_size = 0,
	rounding = math.max(hl.get_config("decoration.rounding") - 6, 0),
	float = true,
	pin = true,
	move = "(monitor_w-window_w-8-7-1) (38+8+7+1)", -- 38 = quickshell bar, 8 = gaps_out, 7 = Zen Browser inner border - 1, 1 = border_size
})

-- Opaque classes
hl.window_rule({
	match = { class = opaque_classes },
	opacity = 1,
})

-- Maximized
hl.window_rule({
	match = { fullscreen_state_client = 1 },
	rounding = 0,
	border_size = 0,
	no_shadow = true,
})

-- Ignore app maximize requests so restored window states do not override tiling.
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Misc rules
hl.window_rule({
	match = { class = "^(Xdg-desktop-portal-gtk|google-chrome)$" },
	no_blur = true,
})
hl.window_rule({
	match = { class = "^(Xdg-desktop-portal-gtk)$" },
	border_size = 0,
})
hl.window_rule({
	match = { class = "^(gcr-prompter)$" },
	animation = "popin",
})
hl.window_rule({
	match = { class = "^(Emulator)$" },
	size = { 61, 512 },
})
hl.window_rule({
	match = { class = "^(flameshot)$" },
	no_anim = true,
})
hl.window_rule({
	match = { float = true },
	animation = "popin",
	center = true,
})
hl.window_rule({
	match = { title = "^win(.*)" },
	rounding = 0,
	border_size = 0,
})
hl.window_rule({
  name = "ueberzugpp",
  match = { class = "^ueberzugpp_.*$" },
  float = true,
  no_focus = true,
  no_anim = true,
  border_size = 0,
  no_shadow = true,
})
