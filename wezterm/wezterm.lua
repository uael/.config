-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.color_scheme = 'Github Dark (Gogh)'
config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.audible_bell = 'Disabled'

-- and finally, return the configuration to wezterm
return config
