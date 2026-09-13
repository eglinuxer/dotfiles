local wezterm = require 'wezterm'
local M = {}
local function tab_name(tab)
  -- A tab is a connection/task label, independent of application OSC titles.
  local name = (tab.tab_title or ''):gsub('%c', ' '):match('^%s*(.-)%s*$')
  return name ~= '' and name or 'local'
end
local function shorten(text, width)
  if width <= 0 then return '' end
  if wezterm.column_width(text) <= width then return text end
  local ellipsis = '…'
  local ellipsis_width = wezterm.column_width(ellipsis)
  if width < ellipsis_width then return wezterm.truncate_right(text, width) end
  return wezterm.truncate_right(text, width - ellipsis_width) .. ellipsis
end
function M.setup()
  wezterm.on('format-tab-title', function(tab, _, _, _, hover, max_width)
    local title = tab_name(tab)
    local number = ' ' .. tostring(tab.tab_index + 1) .. ' '
    -- Reserve both round caps, title padding and the gap between tabs.
    local chrome_width = wezterm.column_width(number) + 5
    if max_width < chrome_width then
      return { { Text = wezterm.truncate_right(tostring(tab.tab_index + 1), max_width) } }
    end
    local title_width = max_width - chrome_width
    title = shorten(title, title_width)
    title = title .. string.rep(' ', title_width - wezterm.column_width(title))
    local accent = tab.is_active and '#cba6f7' or '#7f849c'
    local body = (tab.is_active or hover) and '#45475a' or '#313244'
    return {
      { Attribute = { Intensity = tab.is_active and 'Bold' or 'Normal' } },
      { Background = 'Default' }, { Foreground = { Color = accent } },
      { Text = '' },
      { Background = { Color = accent } }, { Foreground = { Color = '#11111b' } },
      { Text = number },
      { Background = { Color = body } }, { Foreground = { Color = '#cdd6f4' } },
      { Text = ' ' .. title .. ' ' },
      { Background = 'Default' }, { Foreground = { Color = body } },
      { Text = ' ' },
    }
  end)
  wezterm.on('format-window-title', function(tab)
    return shorten(tab_name(tab), 48) .. ' — WezTerm'
  end)
  wezterm.on('augment-command-palette', function()
    local commands = {
      {
        brief = 'Rename connection tab / 重命名连接标签',
        action = wezterm.action.PromptInputLine {
          description = '连接或任务名称（留空恢复 local；SSH 连接请手动命名）',
          action = wezterm.action_callback(function(window, _, line)
            if line ~= nil then window:active_tab():set_title(line) end
          end),
        },
      },
      { brief = 'Copy mode / 终端复制模式', action = wezterm.action.ActivateCopyMode },
      { brief = 'Full screen / 全屏', action = wezterm.action.ToggleFullScreen },
      { brief = 'Debug overlay / 调试信息', action = wezterm.action.ShowDebugOverlay },
    }
    for _, command in ipairs(require('background').commands()) do commands[#commands + 1] = command end
    return commands
  end)
end
return M
