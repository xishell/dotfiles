hl.on("hyprland.start", function()
    -- Authentication agent
    hl.exec_cmd("hyprpolkitagent")

    -- Cursor theme
    hl.exec_cmd("hyprctl setcursor win11-Dark 24")

    -- Status bar
    hl.exec_cmd("waybar")

    -- Audio effects service
    hl.exec_cmd("easyeffects --hide-window --gapplication-service")

    -- Wallpaper
    hl.exec_cmd("hyprpaper")

    -- Clipboard history
    hl.exec_cmd("wl-paste --watch cliphist store")

    -- Idle management
    hl.exec_cmd("hypridle")

    -- Screen sharing / secrets
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
end)
