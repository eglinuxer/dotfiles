local wezterm = require 'wezterm'
local M = {}
function M.apply(config)
  config.font = wezterm.font 'ComicShannsMono Nerd Font Mono'
  config.font_size = 18
  config.initial_cols = 120
  config.initial_rows = 36
  config.adjust_window_size_when_changing_font_size = false
  config.window_background_opacity = 1
  config.window_padding = { left = 6, right = 6, top = 4, bottom = 4 }
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
  config.use_fancy_tab_bar = true
  config.tab_bar_style = {
    new_tab = wezterm.format { { Text = ' ' .. wezterm.nerdfonts.cod_add .. ' ' } },
    new_tab_hover = wezterm.format { { Text = ' ' .. wezterm.nerdfonts.cod_add .. ' ' } },
  }
  -- Catppuccin Mocha chrome, matching the vendored tmux palette.
  config.window_frame = {
    font = wezterm.font 'ComicShannsMono Nerd Font Mono',
    active_titlebar_bg = '#181825',
    inactive_titlebar_bg = '#11111b',
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
      background = '#181825',
      active_tab = { fg_color = '#1e1e2e', bg_color = '#cba6f7', intensity = 'Bold' },
      inactive_tab = { fg_color = '#a6adc8', bg_color = '#1e1e2e' },
      inactive_tab_hover = { fg_color = '#cdd6f4', bg_color = '#313244' },
      new_tab = { fg_color = '#a6adc8', bg_color = '#181825' },
      new_tab_hover = { fg_color = '#cba6f7', bg_color = '#313244' },
    },
  }
end
return M
