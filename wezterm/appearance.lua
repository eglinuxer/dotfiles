local wezterm = require 'wezterm'
local M = {}
function M.apply(config)
  config.font = wezterm.font_with_fallback {
    'ComicShannsMono Nerd Font Mono',
    'Xiaolai Mono',
  }
  config.font_size = 18
  config.line_height = 1.05
  config.initial_cols = 120
  config.initial_rows = 36
  config.adjust_window_size_when_changing_font_size = false
  config.window_background_opacity = 1
  config.window_padding = { left = 12, right = 12, top = 8, bottom = 8 }
  if wezterm.target_triple:find('apple', 1, true) then
    -- Keep native traffic lights in their own title bar, clear of the tabs.
    config.window_decorations = 'TITLE|RESIZE'
  else
    -- Provide window controls even when the compositor supplies no title bar.
    -- Double-click the empty tab bar area to maximize or restore the window.
    config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
    config.integrated_title_buttons = { 'Hide', 'Maximize', 'Close' }
    config.integrated_title_button_alignment = 'Right'
  end
  -- Custom round-capped tabs match the existing Catppuccin tmux modules.
  config.use_fancy_tab_bar = false
  config.tab_bar_style = {
    new_tab = wezterm.format { { Text = ' ' .. wezterm.nerdfonts.cod_add .. ' ' } },
    new_tab_hover = wezterm.format { { Text = ' ' .. wezterm.nerdfonts.cod_add .. ' ' } },
  }
  -- Catppuccin Mocha chrome, matching the vendored tmux palette.
  config.window_frame = {
    font = config.font,
    font_size = 12,
    active_titlebar_bg = '#181825',
    inactive_titlebar_bg = '#11111b',
  }
  config.hide_tab_bar_if_only_one_tab = false
  config.tab_max_width = 30
  config.enable_scroll_bar = false
  -- Catppuccin Mocha throughout the terminal and window chrome.
  config.colors = {
    foreground = '#cdd6f4', background = '#1e1e2e',
    cursor_bg = '#f5e0dc', cursor_border = '#f5e0dc', cursor_fg = '#1e1e2e',
    selection_bg = '#45475a', selection_fg = '#cdd6f4',
    split = '#b4befe', compose_cursor = '#f9e2af',
    ansi = { '#45475a', '#f38ba8', '#a6e3a1', '#f9e2af', '#89b4fa', '#f5c2e7', '#94e2d5', '#bac2de' },
    brights = { '#585b70', '#f38ba8', '#a6e3a1', '#f9e2af', '#89b4fa', '#f5c2e7', '#94e2d5', '#a6adc8' },
    tab_bar = {
      background = '#181825',
      active_tab = { fg_color = '#cdd6f4', bg_color = '#45475a', intensity = 'Bold' },
      inactive_tab = { fg_color = '#a6adc8', bg_color = '#181825' },
      inactive_tab_hover = { fg_color = '#cdd6f4', bg_color = '#313244' },
      new_tab = { fg_color = '#a6adc8', bg_color = '#181825' },
      new_tab_hover = { fg_color = '#b4befe', bg_color = '#313244' },
    },
  }
end
return M
