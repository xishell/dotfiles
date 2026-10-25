hl.on("hyprland.start", function()
    -- Authentication agent
    hl.exec_cmd("hyprpolkitagent")

    -- Cursor theme
    hl.exec_cmd("hyprctl setcursor win11-Dark 24")

    -- Status bar (Ironbar); then show the current couch/desk mode on its chip
    hl.exec_cmd("ironbar")
    hl.exec_cmd("sh -c 'sleep 3; couch barsync'")

    -- Notifications + volume/brightness OSD
    hl.exec_cmd("mako")
    hl.exec_cmd("swayosd-server")

    -- Quickshell mixer (IPC-triggered via Super+A or waybar pulseaudio click)
    hl.exec_cmd("qs -c mixer")

    -- Quickshell media controls (IPC-triggered via Super+P)
    hl.exec_cmd("qs -c media")

    -- Sofa mode: hold both sticks in (L3 + R3) for 1.5 s to toggle sofa / desk
    hl.exec_cmd("couch listen")

    -- Wallpaper
    hl.exec_cmd("hyprpaper")

    -- Clipboard history
    hl.exec_cmd("wl-paste --watch cliphist store")

    -- Screen sharing / secrets
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
end)
