local wezterm = require("wezterm")
local config = wezterm.config_builder()

--config.color_scheme = "Catppuccin Mocha"
--config.color_scheme = "Tokyo Night"
config.color_scheme = "Catppuccin Macchiato"

--config.font = wezterm.font("JetBrains Mono")
config.font_size = 20

config.window_background_opacity = 0.9
--config.window_decorations = "NONE" -- Doesnt play nice with aerospace :(
config.hide_tab_bar_if_only_one_tab = true

config.max_fps = 120

-- Finally, return the configuration to wezterm:
return config
