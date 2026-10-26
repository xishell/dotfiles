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

-- Terminals stay opaque: Ember has blur off, so translucency would show the
-- wallpaper sharply behind text.

-- Any fullscreen window keeps the session awake (hypridle: no lock, no DPMS)
hl.window_rule({
    name  = "idle-inhibit-fullscreen",
    match = { class = ".*" },
    idle_inhibit = "fullscreen",
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

-- Scratchpads (`scratch`, Super+` / Super+Y / Super+D): each app opens on its own
-- special workspace and slides over the current one. Floating so they don't reflow.
hl.window_rule({
    name      = "scratch-term",
    match     = { class = "^dropterm$" },
    workspace = "special:term silent",
    float     = true,
    size      = "monitor_w*0.6 monitor_h*0.45",
    move      = "monitor_w*0.2 54",
})

hl.window_rule({
    name      = "scratch-music",
    match     = { class = "^Spotify$" },
    workspace = "special:music silent",
    float     = true,
    size      = "monitor_w*0.7 monitor_h*0.8",
    center    = true,
})

hl.window_rule({
    name      = "scratch-chat",
    match     = { class = "^vesktop$" },
    workspace = "special:chat silent",
    float     = true,
    size      = "monitor_w*0.7 monitor_h*0.8",
    center    = true,
})

-- No gaps, border or rounding when a workspace holds a single tiled window
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
hl.window_rule({
    name        = "smart-gaps-wtv1",
    match       = { float = false, workspace = "w[tv1]" },
    border_size = 0,
    rounding    = 0,
})
hl.window_rule({
    name        = "smart-gaps-f1",
    match       = { float = false, workspace = "f[1]" },
    border_size = 0,
    rounding    = 0,
})
