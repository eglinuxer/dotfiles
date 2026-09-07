local wezterm = require 'wezterm'
local config = wezterm.config_builder()
require('appearance').apply(config)
require('keys').apply(config)
require('events').setup()
-- Account shell; no automatic tmux attachment or SSH setup.
config.automatically_reload_config = true
config.enable_kitty_keyboard = true
config.scrollback_lines = 10000
config.audible_bell = 'Disabled'
config.exit_behavior = 'CloseOnCleanExit'
config.exit_behavior_messaging = 'Verbose'
config.window_close_confirmation = 'AlwaysPrompt'
config.hyperlink_rules = wezterm.default_hyperlink_rules()
return config
