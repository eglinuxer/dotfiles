local wezterm = require 'wezterm'
local M = {}

-- Shared backdrop; applications keep their default background transparent.
M.settings = {
  default_mode = 'wallpaper', -- glass, wallpaper, focus
  glass_opacity = 0.88,
  macos_blur = 20,
  wallpaper_overlay = 0.94,
  wallpaper = nil, -- Optional absolute path; otherwise choose from backdrops/.
  images_dir = wezterm.config_dir .. '/backdrops',
}

local function readable(path)
  if type(path) ~= 'string' or path == '' then return false end
  local file = io.open(path, 'rb')
  if not file then return false end
  local first_byte = file:read(1)
  file:close()
  return first_byte ~= nil
end

function M.images()
  local images, seen = {}, {}
  local function add(path)
    if not seen[path] and readable(path) then
      seen[path] = true
      images[#images + 1] = path
    end
  end
  if M.settings.wallpaper then add(M.settings.wallpaper) end
  local ok, paths = pcall(wezterm.read_dir, M.settings.images_dir)
  if ok then
    local scanned = {}
    for _, path in ipairs(paths) do
      local ext = path:lower():match('%.([^./]+)$')
      if ext == 'png' or ext == 'jpg' or ext == 'jpeg' or ext == 'gif' or ext == 'bmp' then
        scanned[#scanned + 1] = path
      end
    end
    table.sort(scanned)
    for _, path in ipairs(scanned) do add(path) end
  end
  return images
end

-- Returns a complete mode so an old picture or opacity cannot leak into it.
function M.options(mode, path)
  assert(mode == 'glass' or mode == 'wallpaper' or mode == 'focus', 'unknown background mode')
  local options = { background = {}, window_background_opacity = 1, text_background_opacity = 1 }
  if wezterm.target_triple:find('apple', 1, true) then
    options.macos_window_background_blur = mode == 'glass' and M.settings.macos_blur or 0
  end
  if mode == 'glass' then
    options.window_background_opacity = M.settings.glass_opacity
  elseif mode == 'wallpaper' then
    if not readable(path) then return M.options('focus'), 'focus' end
    options.background = {
      -- The solid base also makes images with an alpha channel fully opaque.
      { source = { Color = '#1e1e2e' }, width = '100%', height = '100%' },
      {
        source = { File = path }, width = 'Cover', height = 'Cover',
        horizontal_align = 'Center', vertical_align = 'Middle',
        repeat_x = 'NoRepeat', repeat_y = 'NoRepeat',
      },
      {
        source = { Color = '#1e1e2e' }, width = '100%', height = '100%',
        opacity = M.settings.wallpaper_overlay,
      },
    }
  end
  return options, mode
end

function M.apply(config)
  local path = M.settings.default_mode == 'wallpaper' and M.images()[1] or nil
  for key, value in pairs(M.options(M.settings.default_mode, path)) do config[key] = value end
end

local function notify(window, message)
  window:toast_notification('WezTerm 背景', message, nil, 5000)
end

local function selected_image(window)
  local remembered = wezterm.GLOBAL['dotfiles.wallpaper.' .. tostring(window:window_id())]
  if readable(remembered) then return remembered end
  for _, layer in ipairs(window:effective_config().background or {}) do
    local file = layer.source and layer.source.File
    if type(file) == 'table' then file = file.path end
    if readable(file) then return file end
  end
end

function M.set_mode(window, mode, path)
  -- GLOBAL survives configuration reloads; each GUI window remembers its image.
  local image_key = 'dotfiles.wallpaper.' .. tostring(window:window_id())
  if mode == 'wallpaper' and path == nil then
    path = selected_image(window) or M.images()[1]
  end
  local options, effective_mode = M.options(mode, path)
  if effective_mode == 'wallpaper' then wezterm.GLOBAL[image_key] = path end
  local overrides = window:get_config_overrides() or {}
  for key, value in pairs(options) do overrides[key] = value end
  window:set_config_overrides(overrides)
  if effective_mode ~= mode then
    notify(window, '未找到可读取的壁纸，已使用纯色专注模式。图片目录：' .. M.settings.images_dir)
  end
end

function M.cycle(window, direction)
  local images = M.images()
  if #images == 0 then M.set_mode(window, 'wallpaper', ''); return end
  local current, index = selected_image(window), nil
  for i, path in ipairs(images) do
    if path == current then index = i; break end
  end
  local next_index = index and ((index - 1 + direction) % #images + 1)
    or (direction > 0 and 1 or #images)
  M.set_mode(window, 'wallpaper', images[next_index])
end

function M.random(window)
  local images, choices = M.images(), {}
  local current = selected_image(window)
  for _, path in ipairs(images) do
    if path ~= current then choices[#choices + 1] = path end
  end
  -- Avoid choosing the current image when there is an alternative.
  if #choices == 0 then choices = images end
  if #choices == 0 then M.set_mode(window, 'wallpaper', ''); return end
  M.set_mode(window, 'wallpaper', choices[math.random(#choices)])
end

function M.toggle_focus(window)
  local config = window:effective_config()
  local mode = (config.window_background_opacity or 1) < 1 and 'glass' or 'focus'
  for _, layer in ipairs(config.background or {}) do
    if layer.source and layer.source.File then mode = 'wallpaper'; break end
  end
  local key = 'dotfiles.focus-return.' .. tostring(window:window_id())
  if mode == 'focus' then
    M.set_mode(window, wezterm.GLOBAL[key] or 'wallpaper')
  else
    -- Remember the initial image too, before removing its background layer.
    local path = selected_image(window)
    if path then wezterm.GLOBAL['dotfiles.wallpaper.' .. tostring(window:window_id())] = path end
    wezterm.GLOBAL[key] = mode
    M.set_mode(window, 'focus')
  end
end

function M.select_image(window, pane)
  local images = M.images()
  if #images == 0 then
    notify(window, '将 PNG / JPG / GIF / BMP 图片放入 ' .. M.settings.images_dir .. '，然后重新打开壁纸选择。')
    return
  end
  local choices = {}
  for _, path in ipairs(images) do
    choices[#choices + 1] = { id = path, label = path:match('[^/]+$') or path }
  end
  window:perform_action(wezterm.action.InputSelector {
    title = '选择背景图片 / Wallpaper', fuzzy = true, choices = choices,
    action = wezterm.action_callback(function(win, _, id)
      if id then M.set_mode(win, 'wallpaper', id) end
    end),
  }, pane)
end

function M.commands()
  local commands = {}
  for _, item in ipairs {
    { 'glass', 'Background: Glass / 毛玻璃背景' },
    { 'wallpaper', 'Background: Wallpaper / 壁纸背景' },
    { 'focus', 'Background: Focus / 纯色专注' },
  } do
    local mode = item[1]
    commands[#commands + 1] = {
      brief = item[2],
      action = wezterm.action_callback(function(window) M.set_mode(window, mode) end),
    }
  end
  commands[#commands + 1] = {
    brief = 'Background: Select wallpaper / 选择壁纸',
    action = wezterm.action_callback(M.select_image),
  }
  return commands
end

return M
