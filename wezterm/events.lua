local wezterm = require 'wezterm'
local M = {}
function M.setup()
  wezterm.on('format-tab-title', function(tab, _, _, _, hover, max_width)
    local title = tab.tab_title
    if not title or title == '' then title = tab.active_pane.title end
    local number = ' ' .. tostring(tab.tab_index + 1) .. ' '
    -- Reserve both round caps, title padding and the gap between tabs.
    local chrome_width = wezterm.column_width(number) + 5
    if max_width < chrome_width then
      return { { Text = wezterm.truncate_right(tostring(tab.tab_index + 1), max_width) } }
    end
    local background = '#181825'
    local accent = tab.is_active and '#cba6f7' or '#7f849c'
    local body = (tab.is_active or hover) and '#45475a' or '#313244'
    return {
      { Attribute = { Intensity = tab.is_active and 'Bold' or 'Normal' } },
      { Background = { Color = background } }, { Foreground = { Color = accent } },
      { Text = '' },
      { Background = { Color = accent } }, { Foreground = { Color = '#11111b' } },
      { Text = number },
      { Background = { Color = body } }, { Foreground = { Color = '#cdd6f4' } },
      { Text = ' ' .. wezterm.truncate_right(title, max_width - chrome_width) .. ' ' },
      { Background = { Color = background } }, { Foreground = { Color = body } },
      { Text = ' ' },
    }
  end)
  wezterm.on('augment-command-palette', function()
    return {
      {
        brief = 'Rename connection tab / 重命名连接标签',
        action = wezterm.action.PromptInputLine {
          description = '连接名称（留空恢复自动标题）',
          action = wezterm.action_callback(function(window, _, line)
            if line ~= nil then window:active_tab():set_title(line) end
          end),
        },
      },
      { brief = 'Copy mode / 终端复制模式', action = wezterm.action.ActivateCopyMode },
      { brief = 'Full screen / 全屏', action = wezterm.action.ToggleFullScreen },
      { brief = 'Debug overlay / 调试信息', action = wezterm.action.ShowDebugOverlay },
    }
  end)
end
return M
