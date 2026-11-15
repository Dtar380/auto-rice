-- ============================================================================
--  ENVIRONMENT VARIABLES
-- ============================================================================

local HOME = os.getenv("HOME")
local PATH = os.getenv("PATH")

hl.env("PATH",
    HOME .. "/.local/bin:" ..
    PATH
)

hl.env("HYPRCURSOR_THEME", "current_cursor")
hl.env("HYPRCURSOR_SIZE", "24")

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

hl.env("GDK_SCALE", "1")
hl.env("GDK_BACKEND", "wayland,x11,*")

hl.env("BROWSER", "zen-browser")

local secrets_path = HOME .. "/.config/hypr/lua/secrets.lua"
local f = io.open(secrets_path, "r")
if f then
    f:close()
else
    f = io.open(secrets_path, "w")
    if f then f:close() end
end

pcall(function () require("lua.secrets") end)
