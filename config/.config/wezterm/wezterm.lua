local wezterm = require("wezterm")

local config = wezterm.config_builder()
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.audible_bell = "Disabled"
config.color_scheme = "tokyonight_night"
config.font = wezterm.font("FiraCode Nerd Font Mono")
config.font_size = 14.0
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true
return config
