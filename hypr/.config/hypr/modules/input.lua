hl.config({
    input = {
        kb_layout  = "gbswe",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse   = 1,
        -- Pointer speed = Windows (1600 DPI, pointer speed 4/11 = x0.5, no acceleration).
        -- Two paths, same as on Windows (verified in Hyprland 0.56 + Wine source):
        --  * raw input (gameplay): Wine reads the unaccelerated delta -> 1600, never scaled
        --  * cursor (desktop AND in-game cursors/menus): the accelerated delta -> x0.5 here
        -- The x0.5 is a straight custom curve (same as flat + sensitivity -0.5). Keep
        -- force_no_accel false: true makes Hyprland's cursor use the raw delta while game
        -- cursors still get the scaled one, so menus feel slower than the desktop.
        sensitivity    = 0.0,
        accel_profile  = "custom 1 0 0.5",
        force_no_accel = false,

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
