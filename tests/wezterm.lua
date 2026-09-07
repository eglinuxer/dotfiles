-- Native WezTerm Lua validation. Run: wezterm --config-file tests/wezterm.lua show-keys --lua
local wezterm = require 'wezterm'
local root = wezterm.config_dir .. '/..'
package.path = root .. '/wezterm/?.lua;' .. package.path
local handlers = {}
local original_on = wezterm.on
wezterm.on = function(name, callback) handlers[name] = callback end
require('events').setup()
wezterm.on = original_on
local title = handlers['format-tab-title']
local local_title = title({ tab_index=0, tab_title='' },nil,nil,nil,nil,30)[1].Text
assert(local_title == ' 1  local ')
local long_title = title({ tab_index=1, tab_title='远程开发服务器测试名称' },nil,nil,nil,nil,12)[1].Text
assert(wezterm.column_width(long_title) <= 12)
local palette = handlers['augment-command-palette']()
assert(#palette == 4 and palette[1].brief:find('Rename'))
local config = dofile(root .. '/wezterm/wezterm.lua')
assert(config.disable_default_key_bindings and config.key_map_preference == 'Physical')
assert(#config.keys == 13)
for _, key in ipairs(config.keys) do
  assert(key.mods == 'CTRL|SHIFT', 'unexpected global shortcut')
end
assert(config.scrollback_lines == 10000 and config.font_size == 14)
assert(config.default_prog == nil, 'must use account shell')
return config
