local wezterm = require 'wezterm'
local M = {}
function M.apply(config)
  config.font = wezterm.font 'JetBrains Mono'
  config.font_size = 14
  config.initial_cols = 120
  config.initial_rows = 36
  config.adjust_window_size_when_changing_font_size = false
  config.window_background_opacity = 1
  config.window_padding = { left = 6, right = 6, top = 4, bottom = 4 }
  -- Provide window controls even when the compositor supplies no title bar.
  -- Double-click the empty tab bar area to maximize or restore the window.
  config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
  config.integrated_title_buttons = { 'Hide', 'Maximize', 'Close' }
  config.integrated_title_button_alignment = 'Right'
  config.use_fancy_tab_bar = true
  config.window_frame = {
    active_titlebar_bg = '#111317',
    inactive_titlebar_bg = '#111317',
  }
  config.hide_tab_bar_if_only_one_tab = false
  config.tab_max_width = 30
  config.enable_scroll_bar = false
  -- Static AstroTheme Astrodark palette; see docs/theme-source.md.
  config.colors = {
    foreground = '#ADB0BB', background = '#1A1D23',
    cursor_bg = '#ADB0BB', cursor_border = '#ADB0BB', cursor_fg = '#1A1D23',
    selection_bg = '#26343F', selection_fg = '#ADB0BB',
    split = '#50A4E9', compose_cursor = '#EB8332',
    ansi = { '#111317', '#FF838B', '#87C05F', '#DFAB25', '#5EB7FF', '#DD97F1', '#4AC2B8', '#9B9FA9' },
    brights = { '#34363A', '#FFA6AE', '#AAE382', '#FFCE48', '#81DAFF', '#FFBAFF', '#6DE5DB', '#D0D3DE' },
    tab_bar = {
      background = '#111317',
      active_tab = { fg_color = '#111317', bg_color = '#50A4E9', intensity = 'Bold' },
      inactive_tab = { fg_color = '#ADB0BB', bg_color = '#16181D' },
      inactive_tab_hover = { fg_color = '#5EB7FF', bg_color = '#26343F' },
      new_tab = { fg_color = '#ADB0BB', bg_color = '#111317' },
      new_tab_hover = { fg_color = '#5EB7FF', bg_color = '#26343F' },
    },
  }
end
return M
