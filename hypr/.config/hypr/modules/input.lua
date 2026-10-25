hl.config({
    input = {
        kb_layout  = "gbswe",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse   = 1,
        sensitivity    = 0.0,  -- must stay 0: force_no_accel bypasses this for the
                               -- compositor cursor, but NOT for wp_relative_pointer
                               -- deltas, which Wine hands games as raw input. A
                               -- negative value here silently slows game menus
                               -- (e.g. Cyberpunk) while the desktop feels fine.
                               -- Set pointer speed via mouse DPI instead.
        accel_profile  = "flat",
        force_no_accel = true,

        repeat_rate  = 25,
        repeat_delay = 400,

        touchpad = {
            natural_scroll       = false,
            disable_while_typing = true,
            tap_to_click         = true,
            clickfinger_behavior = true,
        },
    },
})
