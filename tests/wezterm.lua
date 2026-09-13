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
local auto_tab = { tab_index=0, tab_title='', active_pane={ title='zsh' } }
local function rendered_title(tab, width)
  local parts = {}
  for _, item in ipairs(title(tab,nil,nil,nil,false,width or 30)) do
    if item.Text then table.insert(parts, item.Text) end
  end
  return table.concat(parts)
end
local prefix = ' 1  '
assert(rendered_title(auto_tab) == prefix .. 'zsh  ')
auto_tab.active_pane.title = 'nvim'
assert(rendered_title(auto_tab) == prefix .. 'nvim  ')
auto_tab.tab_title = 'server'
assert(rendered_title(auto_tab) == prefix .. 'server  ')
auto_tab.tab_title = ''
assert(rendered_title(auto_tab) == prefix .. 'nvim  ')
for width = 1, 30 do
  local long_title = rendered_title({ tab_index=1, tab_title='远程开发服务器测试名称' }, width)
  assert(wezterm.column_width(long_title) <= width)
end
local palette = handlers['augment-command-palette']()
assert(#palette == 4 and palette[1].brief:find('Rename'))
local config = dofile(root .. '/wezterm/wezterm.lua')
assert(config.disable_default_key_bindings and config.key_map_preference == 'Physical')
assert(#config.keys == 20)
for _, key in ipairs(config.keys) do
  if key.mods == 'ALT' then
    assert(key.key:match('^[1-9]$'), 'unexpected Alt shortcut')
    assert(key.action.ActivateTab == tonumber(key.key) - 1)
  else
    assert(key.mods == 'CTRL|SHIFT', 'unexpected global shortcut')
  end
end
assert(config.scrollback_lines == 10000 and config.font_size == 18)
assert(config.default_prog == nil, 'must use account shell')
return config
