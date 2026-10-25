-- User scripts (menu-tools, gaming-mode-toggle, spotify wrapper, ...). ly starts
-- Hyprland without a login shell, so ~/.local/bin is not on PATH otherwise.
local home = os.getenv("HOME")
local path = os.getenv("PATH") or "/usr/local/bin:/usr/bin"
if not path:find(home .. "/.local/bin", 1, true) then
    hl.env("PATH", home .. "/.local/bin:" .. path)
end

-- Cursor size
hl.env("XCURSOR_SIZE",    "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Wayland-native application support
hl.env("QT_QPA_PLATFORM",                    "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME",               "qt5ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_BACKEND",                        "wayland,x11")
hl.env("SDL_VIDEODRIVER",                    "wayland")
hl.env("CLUTTER_BACKEND",                    "wayland")
hl.env("XDG_CURRENT_DESKTOP",                "Hyprland")
hl.env("XDG_SESSION_TYPE",                   "wayland")
hl.env("XDG_SESSION_DESKTOP",                "Hyprland")

-- Dark mode preferences
hl.env("GTK_THEME",         "Tokyonight-Dark")
hl.env("QT_STYLE_OVERRIDE", "Adwaita-Dark")
hl.env("XCURSOR_THEME",     "win11-Dark")

-- Nvidia
hl.env("LIBVA_DRIVER_NAME",          "nvidia")
hl.env("GBM_BACKEND",                "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME",  "nvidia")
hl.env("WLR_NO_HARDWARE_CURSORS",    "1")

-- Permissions
hl.config({
    ecosystem = {
        enforce_permissions = true,
    },
})

hl.permission("/usr/(bin|local/bin)/grim",                              "screencopy", "allow")
hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland",   "screencopy", "allow")
hl.permission("/usr/(bin|local/bin)/hyprpm",                            "plugin",     "allow")
