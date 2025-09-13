local wezterm = require("wezterm")
local platform = require("utils.platform")

local M = {}

-- 背景图片索引
M.current_bg_index = 1

-- 获取背景图片目录
local function get_backgrounds_dir()
    local home = platform.get_home()
    local sep = platform.path_separator()
    return home .. sep .. ".config" .. sep .. "wezterm" .. sep .. "backgrounds"
end

-- 获取所有背景图片
function M.get_background_images()
    local backgrounds_dir = get_backgrounds_dir()
    local images = {}

    -- 支持的图片格式
    local extensions = { "jpg", "jpeg", "png", "gif", "bmp" }

    for _, ext in ipairs(extensions) do
        local pattern = backgrounds_dir .. "/*." .. ext
        for _, file in ipairs(wezterm.glob(pattern)) do
            table.insert(images, file)
        end
    end

    return images
end

-- 切换到下一张背景图片
function M.switch_background(window, direction)
    local images = M.get_background_images()
    if #images == 0 then
        window:toast_notification("WezTerm", "No background images found in backgrounds/ directory", nil, 3000)
        return
    end

    -- 获取当前配置
    local overrides = window:get_config_overrides() or {}

    -- 更新索引
    if direction == "next" then
        M.current_bg_index = M.current_bg_index % #images + 1
    elseif direction == "prev" then
        M.current_bg_index = M.current_bg_index - 1
        if M.current_bg_index < 1 then
            M.current_bg_index = #images
        end
    elseif direction == "random" then
        M.current_bg_index = math.random(1, #images)
    end

    -- 获取文件名用于显示
    local image_path = images[M.current_bg_index]
    local image_name = string.match(image_path, "([^/\\]+)$")

    -- 设置新的背景配置
    overrides.background = {
        -- 第一层：纯色背景（完全不透明）
        {
            source = {
                Color = "#1e2030",  -- Tokyo Night 背景色
            },
            width = "100%",
            height = "100%",
            opacity = 1.0,
        },
        -- 第二层：背景图片
        {
            source = {
                File = image_path,
            },
            width = "Cover",
            height = "Cover",
            horizontal_align = "Center",
            vertical_align = "Middle",
            opacity = 0.3,
            hsb = {
                brightness = 0.3,
                saturation = 0.9,
            },
        },
    }

    -- 应用配置
    window:set_config_overrides(overrides)

    -- 显示通知
    window:toast_notification(
        "Background Changed",
        string.format("Switched to: %s (%d/%d)", image_name, M.current_bg_index, #images),
        nil,
        2000
    )
end

-- 设置背景切换事件
function M.setup()
    -- 注册自定义事件处理
    wezterm.on("switch-background", function(window, pane)
        M.switch_background(window, "next")
    end)

    wezterm.on("switch-background-prev", function(window, pane)
        M.switch_background(window, "prev")
    end)

    wezterm.on("switch-background-random", function(window, pane)
        M.switch_background(window, "random")
    end)
end

return M
