-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.color_scheme = 'Github Dark (Gogh)'
config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.audible_bell = 'Disabled'
config.set_environment_variables = {
  ["PATH"] = '/etc/profiles/per-user/'..os.getenv('USER')..'/bin:'..os.getenv('PATH')
}
config.default_prog = { 'fish', '-l' }
config.native_macos_fullscreen_mode = true

-- FIXME: workaround https://github.com/wez/wezterm/issues/5990
config.front_end = "WebGpu"

-- and finally, return the configuration to wezterm
return config
