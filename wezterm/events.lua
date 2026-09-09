local wezterm = require 'wezterm'
local M = {}
function M.setup()
  wezterm.on('format-tab-title', function(tab, _, _, _, _, max_width)
    local title = tab.tab_title
    if not title or title == '' then title = tab.active_pane.title end
    local prefix = wezterm.nerdfonts.cod_terminal .. ' ' .. tostring(tab.tab_index + 1) .. '  '
    local available = math.max(0, max_width - wezterm.column_width(prefix) - 2)
    return { { Text = ' ' .. prefix .. wezterm.truncate_right(title, available) .. ' ' } }
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
