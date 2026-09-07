local wezterm = require 'wezterm'
local act = wezterm.action
local M = {}
function M.apply(config)
  -- Allowlist: Alt, Ctrl+hjkl, Ctrl+arrows and bare F keys pass through.
  config.disable_default_key_bindings = true
  -- Keep Ctrl+Shift+= / 0 bound to the physical keys even when SHIFT produces + / ).
  config.key_map_preference = 'Physical'
  config.keys = {
    { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab 'DefaultDomain' },
    { key = 'n', mods = 'CTRL|SHIFT', action = act.SpawnWindow },
    { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentTab { confirm = true } },
    { key = 'PageUp', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
    { key = 'PageDown', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(1) },
    { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
    { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
    { key = 'f', mods = 'CTRL|SHIFT', action = act.Search { CaseInSensitiveString = '' } },
    { key = 'p', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },
    { key = 'r', mods = 'CTRL|SHIFT', action = act.ReloadConfiguration },
    { key = '=', mods = 'CTRL|SHIFT', action = act.IncreaseFontSize },
    { key = '-', mods = 'CTRL|SHIFT', action = act.DecreaseFontSize },
    { key = '0', mods = 'CTRL|SHIFT', action = act.ResetFontSize },
  }
  config.bypass_mouse_reporting_modifiers = 'SHIFT'
  config.mouse_bindings = {
    -- SHIFT bypass removes SHIFT before matching this CTRL binding.
    { event = { Up = { streak = 1, button = 'Left' } }, mods = 'CTRL', action = act.OpenLinkAtMouseCursor },
  }
end
return M
