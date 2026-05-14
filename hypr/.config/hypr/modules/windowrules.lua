hl.window_rule({
    name  = "float-otter-launcher",
    match = { class = "^otter-launcher$" },
    float = true,
    size  = "620 420",
    center = true,
    animation = "popin",
})

hl.window_rule({
    name  = "float-cht",
    match = { class = "^cht-float$" },
    float = true,
    size  = "700 500",
    center = true,
    animation = "popin",
})

-- Ignore maximize requests from all apps
hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix XWayland dragging issues
hl.window_rule({
    name  = "fix-xwayland-drag",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "float-file-dialogs",
    match = { title = "^(Open File|Save File|Select a File|Choose a file)$" },
    float = true,
    size  = "800 600",
    center = true,
})

hl.window_rule({
    name  = "float-system-utils",
    match = { class = "^(pavucontrol|nm-connection-editor|blueman-manager)$" },
    float = true,
    center = true,
})

hl.window_rule({
    name  = "float-calculators",
    match = { class = "^(org.gnome.Calculator|qalculate-gtk|galculator)$" },
    float = true,
    center = true,
})

-- Picture-in-picture
hl.window_rule({
    name  = "pip-window",
    match = { title = "^(Picture-in-Picture|Picture in picture)$" },
    float = true,
    pin   = true,
    size  = "640 360",
    move  = "100%-660 100%-390",
})

hl.window_rule({
    name  = "float-yazi",
    match = { class = "^yazi-fm$" },
    float = true,
    size  = "1200 800",
    center = true,
})

-- Steam sub-windows (settings, friends) float and center; main Steam stays tiled
hl.window_rule({
    name  = "float-steam-subwindows",
    match = { class = "^steam$", title = ".+" },
    float = true,
    center = true,
})

hl.window_rule({
    name  = "tile-steam-main",
    match = { class = "^steam$", title = "^Steam$" },
    tile  = true,
})

hl.window_rule({
    name  = "terminal-opacity",
    match = { class = "^(Alacritty|kitty|foot)$" },
    opacity = "0.95 0.85",
})

-- Gaming quality-of-life
hl.window_rule({
    name  = "steam-game-focus",
    match = { class = "^(steam_app_.*)$" },
    suppress_event = "activate activatefocus",
    render_unfocused = true,
})

hl.window_rule({
    name  = "generic-game-content",
    match = { content = 3 },
    render_unfocused = true,
    idle_inhibit = "focus",
})

hl.window_rule({
    name  = "gamescope-focus",
    match = { class = "^gamescope$" },
    render_unfocused = true,
})

hl.window_rule({
    name  = "game-idle-inhibit",
    match = { class = "^(steam_app_.*|gamescope|lutris|heroic)$" },
    idle_inhibit = "focus",
})

-- Keep system awake while fullscreen media plays
hl.window_rule({
    name  = "media-idle-inhibit",
    match = { class = "^(mpv|vlc|firefox)$" },
    idle_inhibit = "fullscreen",
})
