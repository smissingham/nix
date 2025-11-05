local wezterm = require("wezterm")
local config = wezterm.config_builder()


----- # General Display Settings # -----
--config.color_scheme = "Catppuccin Mocha"
--config.color_scheme = "Tokyo Night"
--config.font = wezterm.font("JetBrains Mono")
config.max_fps = 120
config.color_scheme = "Tokyo Night"
config.font_size = 16

----- # General Window Settings # -----
config.window_background_opacity = 0.95
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
  left   = 5,
  right  = 5,
  top    = 5,
  bottom = 5
}

----- # Linux Related Settings # -----
config.enable_wayland = false




return config
