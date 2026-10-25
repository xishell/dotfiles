hl.config({
    input = {
        kb_layout  = "gbswe",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse   = 1,
        -- Pointer speed = Windows: mouse at 1600 DPI (games read those raw counts, like
        -- Windows raw input; REDengine menus too), desktop cursor halved like Windows'
        -- pointer speed 4/11 with Enhance pointer precision off. The halving is a straight
        -- custom libinput curve (slope 0.5, no acceleration): it only touches the cursor.
        -- sensitivity must stay 0: Hyprland also applies it to wp_relative_pointer
        -- deltas, which Wine hands games as raw input (it once made Cyberpunk 4x slow).
        sensitivity    = 0.0,
        accel_profile  = "custom 1 0 0.5",
        force_no_accel = false,  -- true would bypass the curve above

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
