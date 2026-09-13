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
  local items = title(tab,nil,nil,nil,false,width or 24)
  assert(type(wezterm.format(items)) == 'string')
  for _, item in ipairs(items) do
    if item.Text then table.insert(parts, item.Text) end
  end
  return table.concat(parts)
end
local prefix = ' 1  '
local default_title = prefix .. 'local' .. string.rep(' ', 11) .. '  '
assert(rendered_title(auto_tab) == default_title)
auto_tab.active_pane.title = 'nvim'
assert(rendered_title(auto_tab) == default_title)
auto_tab.tab_title = 'server'
assert(rendered_title(auto_tab) == prefix .. 'server' .. string.rep(' ', 10) .. '  ')
assert(handlers['format-window-title'](auto_tab) == 'server — WezTerm')
auto_tab.tab_title = ''
assert(rendered_title(auto_tab) == default_title)
assert(handlers['format-window-title'](auto_tab) == 'local — WezTerm')
for _, name in ipairs({ 'dev', '远程开发服务器测试名称', 'billing-service-production', '开发 backend 日志' }) do
  for _, index in ipairs({ 0, 9, 99 }) do
    for width = 0, 30 do
      local rendered = rendered_title({ tab_index=index, tab_title=name }, width)
      assert(wezterm.column_width(rendered) <= width)
      if width >= #tostring(index + 1) + 7 then
        assert(wezterm.column_width(rendered) == width, 'tab must fill its allocated width')
      end
    end
  end
end
assert(rendered_title({ tab_index=0, tab_title='billing-service-production' }):find('…', 1, true))
assert(rendered_title({ tab_index=0, tab_title='  \n  ' }) == default_title)
assert(handlers['format-window-title']({ tab_title='  dev\nlogs  ' }) == 'dev logs — WezTerm')
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
assert(config.tab_max_width == 24)
assert(config.default_prog == nil, 'must use account shell')
return config
