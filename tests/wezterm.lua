-- Native WezTerm Lua validation. Run: python3 tests/wezterm.py
local wezterm = require 'wezterm'
local function run()
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
assert(#palette == 8 and palette[1].brief:find('Rename'))
-- Exercise real native color parsing: curved caps must reset to the canvas.
local tab_items = title(auto_tab,nil,nil,nil,false,24)
assert(tab_items[2].Background == 'Default' and tab_items[11].Background == 'Default')

local background = require 'background'
local saved_settings = background.settings
background.settings = {
  default_mode = 'glass', glass_opacity = 0.9, macos_blur = 20,
  wallpaper_overlay = 0.96, images_dir = '/missing-dotfiles-background-test',
}
local original_read_dir, original_open = wezterm.read_dir, io.open
wezterm.read_dir = function() return { '/mock/z.JPG', '/mock/a.png', '/mock/notes.txt', '/mock/empty.png' } end
io.open = function(path, mode)
  if path == '/mock/a.png' or path == '/mock/z.JPG' then
    return { read = function() return 'x' end, close = function() end }
  elseif path == '/mock/empty.png' then
    return { read = function() return nil end, close = function() end }
  end
  return original_open(path, mode)
end
local images = background.images()
assert(#images == 2 and images[1] == '/mock/a.png' and images[2] == '/mock/z.JPG')
local function fake_window(id)
  return {
    overrides = { font_size = 21, enable_tab_bar = false },
    window_id = function() return id end,
    effective_config = function(self) return self.overrides end,
    get_config_overrides = function(self) return self.overrides end,
    set_config_overrides = function(self, opts) self.overrides = opts end,
    toast_notification = function(self) self.notified = true end,
    perform_action = function(self, action) self.action = action end,
  }
end
local window = fake_window('test-one')
local other = fake_window('test-two')
background.set_mode(window, 'wallpaper', '/mock/z.JPG')
assert(#window.overrides.background == 3)
assert(window.overrides.background[2].source.File == '/mock/z.JPG')
assert(window.overrides.background[3].opacity == 0.96)
assert(window.overrides.window_background_opacity == 1)
background.set_mode(window, 'glass')
assert(#window.overrides.background == 0 and window.overrides.window_background_opacity == 0.9)
background.set_mode(window, 'focus')
assert(#window.overrides.background == 0 and window.overrides.window_background_opacity == 1)
background.set_mode(window, 'wallpaper')
assert(window.overrides.background[2].source.File == '/mock/z.JPG', 'focus round trip lost selected wallpaper')
background.set_mode(other, 'wallpaper')
assert(other.overrides.background[2].source.File == '/mock/a.png', 'wallpaper leaked between windows')
assert(window.overrides.font_size == 21 and window.overrides.enable_tab_bar == false, 'overrides were discarded')
assert(window.overrides.text_background_opacity == 1, 'semantic background colors must stay opaque')
if wezterm.target_triple:find('apple', 1, true) then
  assert(window.overrides.macos_window_background_blur == 0)
  assert(background.options('glass').macos_window_background_blur == 20)
end
background.select_image(window, nil)
assert(window.action.InputSelector.fuzzy and #window.action.InputSelector.choices == 2)
background.cycle(window, 1)
assert(window.overrides.background[2].source.File == '/mock/a.png', 'next must wrap from last to first')
background.cycle(window, -1)
assert(window.overrides.background[2].source.File == '/mock/z.JPG', 'previous must wrap from first to last')
background.random(window)
assert(window.overrides.background[2].source.File == '/mock/a.png', 'random must change image when alternatives exist')
background.toggle_focus(window)
assert(#window.overrides.background == 0 and window.overrides.window_background_opacity == 1)
background.toggle_focus(window)
assert(window.overrides.background[2].source.File == '/mock/a.png', 'focus toggle must restore wallpaper')
background.set_mode(window, 'glass')
background.toggle_focus(window)
background.toggle_focus(window)
assert(window.overrides.window_background_opacity == 0.9, 'focus toggle must restore glass too')
wezterm.read_dir = function() return { '/mock/a.png' } end
background.random(window)
background.cycle(window, 1)
assert(window.overrides.background[2].source.File == '/mock/a.png', 'single-image controls failed')
wezterm.read_dir = function() error('missing directory') end
assert(#background.images() == 0)
background.cycle(window, -1)
background.random(window)
assert(window.notified and #window.overrides.background == 0, 'empty-image controls must safely fall back')
background.set_mode(other, 'wallpaper', '/missing-dotfiles-background-test/deleted.jpg')
assert(other.notified and #other.overrides.background == 0 and other.overrides.window_background_opacity == 1)
other.notified = false
local prior = other.overrides
background.select_image(other, nil)
assert(other.notified and other.overrides == prior, 'empty selector changed background')
wezterm.GLOBAL['dotfiles.wallpaper.test-one'] = nil
wezterm.GLOBAL['dotfiles.wallpaper.test-two'] = nil
wezterm.GLOBAL['dotfiles.focus-return.test-one'] = nil
wezterm.read_dir, io.open = original_read_dir, original_open
background.settings = saved_settings
background.settings.images_dir = root .. '/wezterm/backdrops'
local config = dofile(root .. '/wezterm/wezterm.lua')
assert(config.disable_default_key_bindings and config.key_map_preference == 'Physical')
assert(#config.keys == 25)
local mac = wezterm.target_triple:find('apple', 1, true)
local bg_mods = mac and 'SUPER' or 'CTRL|SHIFT'
local select_mods = mac and 'SUPER|CTRL' or 'CTRL|SHIFT|ALT'
local background_keys = { [','] = true, ['.'] = true, ['/'] = true, b = true }
local found, seen = 0, {}
for _, key in ipairs(config.keys) do
  local chord = key.mods .. ':' .. key.key
  assert(not seen[chord], 'duplicate shortcut: ' .. chord)
  seen[chord] = true
  if key.mods == 'ALT' then
    assert(key.key:match('^[1-9]$'), 'unexpected Alt shortcut')
    assert(key.action.ActivateTab == tonumber(key.key) - 1)
  elseif (key.mods == bg_mods and background_keys[key.key]) or (key.mods == select_mods and key.key == '/') then
    found = found + 1
    assert(key.action.EmitEvent, 'background shortcut must invoke its callback')
  else
    assert(key.mods == 'CTRL|SHIFT', 'unexpected global shortcut')
  end
end
assert(found == 5, 'background shortcuts missing')
assert(config.scrollback_lines == 10000 and config.font_size == 18)
assert(config.tab_max_width == 24)
assert(config.default_prog == nil, 'must use account shell')
return config
end

-- show-keys can silently fall back to default bindings after a Lua failure.
-- Emit a test-only binding so the runner verifies actual execution, not exit 0.
local ok, config = pcall(run)
if not ok then
  return {
    disable_default_key_bindings = true,
    keys = { { key = 'F24', action = wezterm.action.SendString('DOTFILES_WEZTERM_TEST_FAIL: ' .. tostring(config)) } },
  }
end
table.insert(config.keys, { key = 'F24', action = wezterm.action.SendString('DOTFILES_WEZTERM_TEST_PASS') })
return config
