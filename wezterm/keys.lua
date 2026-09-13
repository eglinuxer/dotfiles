local wezterm = require 'wezterm'
local act = wezterm.action
local M = {}
function M.apply(config)
  -- Allowlist: Alt except 1-9, Ctrl+hjkl, Ctrl+arrows and bare F keys pass through.
  config.disable_default_key_bindings = true
  -- Keep Ctrl+Shift+= / 0 bound to the physical keys even when SHIFT produces + / ).
  config.key_map_preference = 'Physical'
  config.keys = {
    { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab 'DefaultDomain' },
    { key = 'n', mods = 'CTRL|SHIFT', action = act.SpawnWindow },
    { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentTab { confirm = true } },
    { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
    { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
    { key = 'f', mods = 'CTRL|SHIFT', action = act.Search { CaseInSensitiveString = '' } },
    { key = 'p', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },
    { key = 'r', mods = 'CTRL|SHIFT', action = act.ReloadConfiguration },
    { key = '=', mods = 'CTRL|SHIFT', action = act.IncreaseFontSize },
    { key = '-', mods = 'CTRL|SHIFT', action = act.DecreaseFontSize },
    { key = '0', mods = 'CTRL|SHIFT', action = act.ResetFontSize },
  }
  for i = 1, 9 do
    table.insert(config.keys, { key = tostring(i), mods = 'ALT', action = act.ActivateTab(i - 1) })
  end
  -- Match the reference's macOS background shortcuts. Elsewhere keep Alt
  -- available to terminal applications and use the existing GUI modifiers.
  local background = require 'background'
  local mac = wezterm.target_triple:find('apple', 1, true)
  local mods = mac and 'SUPER' or 'CTRL|SHIFT'
  local select_mods = mac and 'SUPER|CTRL' or 'CTRL|SHIFT|ALT'
  for _, binding in ipairs {
    { key = ',', mods = mods, action = wezterm.action_callback(function(window) background.cycle(window, -1) end) },
    { key = '.', mods = mods, action = wezterm.action_callback(function(window) background.cycle(window, 1) end) },
    { key = '/', mods = mods, action = wezterm.action_callback(background.random) },
    { key = '/', mods = select_mods, action = wezterm.action_callback(background.select_image) },
    { key = 'b', mods = mods, action = wezterm.action_callback(background.toggle_focus) },
  } do
    table.insert(config.keys, binding)
  end
  config.bypass_mouse_reporting_modifiers = 'SHIFT'
  config.mouse_bindings = {
    -- SHIFT bypass removes SHIFT before matching this CTRL binding.
    { event = { Up = { streak = 1, button = 'Left' } }, mods = 'CTRL', action = act.OpenLinkAtMouseCursor },
  }
end
return M
