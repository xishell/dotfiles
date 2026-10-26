local c = require("modules.palette")

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 2,

        -- Hearth: focus gradient orange → orchid, everything else surface
        col = {
            active_border   = { colors = { c.orange, c.magenta }, angle = 135 },
            inactive_border = c.surface,
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "master",
    },

    decoration = {
        rounding         = 10,
        rounding_power   = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = { enabled = false },
        blur   = { enabled = false },
    },

    animations = {
        enabled = true,
    },

    -- Master layout: monad tall style, master on left.
    master = {
        new_status  = "slave",
        new_on_top  = false,
        orientation = "left",
        mfact       = 0.55,
    },

    misc = {
        -- VRR in fullscreen only (games). The per-monitor `vrr` key is ignored in the Lua
        -- config; misc.vrr applies to every output (DP-1 and the C2 both support it).
        vrr                     = 2,
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
        render_unfocused_fps    = 60,
        font_family             = "FiraCode Nerd Font",
    },
})

-- Curves: ease-out only, no overshoot
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.curve("easeOutCubic", { type = "bezier", points = { {0.33, 1}, {0.68, 1} } })

-- Animations: 150-200 ms (speed is in 100 ms units)
hl.animation({ leaf = "global",     enabled = true, speed = 2,   bezier = "easeOutCubic" })
hl.animation({ leaf = "border",     enabled = true, speed = 2,   bezier = "easeOutCubic" })
hl.animation({ leaf = "windows",    enabled = true, speed = 2,   bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 2,   bezier = "easeOutQuint", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.5, bezier = "easeOutCubic", style = "popin 90%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 1.5, bezier = "easeOutCubic" })
hl.animation({ leaf = "layers",     enabled = true, speed = 1.5, bezier = "easeOutCubic", style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2,   bezier = "easeOutCubic", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 2,   bezier = "easeOutCubic" })
