local wezterm = require("wezterm")
local platform = require("utils.platform")

local M = {}

-- 主题配置
M.themes = {
    ["tokyo-night"] = "Tokyo Night",
    ["tokyo-night-storm"] = "Tokyo Night Storm",
    ["tokyo-night-moon"] = "Tokyo Night Moon",
    ["nord"] = "nord",
}

-- 当前主题（可以通过快捷键切换）
M.current_theme = "tokyo-night"

-- 获取背景图片目录
local function get_backgrounds_dir()
    local home = platform.get_home()
    local sep = platform.path_separator()
    return home .. sep .. ".config" .. sep .. "wezterm" .. sep .. "backgrounds"
end

-- 获取所有背景图片
local function get_background_images()
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

function M.apply_to_config(config)
    -- 设置主题
    config.color_scheme = M.themes[M.current_theme]

    -- 窗口外观
    config.window_decorations = "TITLE | RESIZE"  -- 显示标题栏和所有按钮
    config.enable_tab_bar = true
    config.tab_bar_at_bottom = true  -- 标签栏放在底部
    config.use_fancy_tab_bar = true
    config.hide_tab_bar_if_only_one_tab = false

    -- 关闭窗口透明效果，确保背景图片正常显示
    config.window_background_opacity = 1.0  -- 完全不透明
    config.text_background_opacity = 1.0  -- 文本背景完全不透明

    -- 平台特定设置
    if platform.is_macos() then
        config.macos_window_background_blur = 0  -- 关闭模糊
    elseif platform.is_windows() then
        config.win32_system_backdrop = "Disable"  -- 关闭 Acrylic
    end

    -- 背景图片设置
    local backgrounds = get_background_images()
    if #backgrounds > 0 then
        -- 使用多层背景：先纯色背景，再背景图片
        config.background = {
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
                    File = backgrounds[1],
                },
                width = "Cover",
                height = "Cover",
                horizontal_align = "Center",
                vertical_align = "Middle",
                opacity = 0.3, -- 背景图片透明度（提高到30%）
                hsb = {
                    brightness = 0.3, -- 适度亮度
                    saturation = 0.9,
                },
            },
        }
    end

    -- 光标
    config.default_cursor_style = "BlinkingBar"
    config.cursor_blink_rate = 500
    config.cursor_blink_ease_in = "Constant"
    config.cursor_blink_ease_out = "Constant"

    -- 滚动条
    config.enable_scroll_bar = true
    config.min_scroll_bar_height = "2cell"
    config.colors = {
        scrollbar_thumb = "#81a1c1",  -- 滚动条颜色（更亮的 Nord 蓝色）
    }

    -- 窗口内边距（右边留更多空间给滚动条）
    config.window_padding = {
        left = 10,
        right = 15,  -- 减少右边距，让滚动条更明显
        top = 10,
        bottom = 10,
    }

    -- Tab bar 样式
    config.tab_max_width = 32
    config.show_tab_index_in_tab_bar = false  -- 已在 format-tab-title 中自定义
    config.switch_to_last_active_tab_when_closing_tab = true
    config.show_new_tab_button_in_tab_bar = true

    -- 自定义标签栏按钮样式
    config.tab_bar_style = {
        new_tab = " + ",
        new_tab_hover = " + ",
        window_hide = "  ",
        window_hide_hover = "  ",
        window_maximize = "  ",
        window_maximize_hover = "  ",
        window_close = "  ",
        window_close_hover = "  ",
    }

    -- Tab bar 颜色（与 Tokyo Night 主题协调）
    config.colors = {
        scrollbar_thumb = "#81a1c1",  -- 滚动条颜色（更亮的 Nord 蓝色）

        -- Pane 分割线配置（增强可见性）
        split = "#7aa2f7",  -- 使用明亮的蓝色作为分割线颜色

        tab_bar = {
            background = "#1a1b26",  -- 标签栏背景
            active_tab = {
                bg_color = "#7aa2f7",
                fg_color = "#1e2030",
                intensity = "Bold",
            },
            inactive_tab = {
                bg_color = "#3b4261",
                fg_color = "#c0caf5",
            },
            inactive_tab_hover = {
                bg_color = "#545c7e",
                fg_color = "#c0caf5",
                italic = false,
            },
            new_tab = {
                bg_color = "#1a1b26",
                fg_color = "#7aa2f7",
            },
            new_tab_hover = {
                bg_color = "#3b4261",
                fg_color = "#7aa2f7",
            },
        },
    }

    -- 非活动 pane 的调暗效果（让活动 pane 更突出）
    config.inactive_pane_hsb = {
        saturation = 0.7,  -- 降低饱和度
        brightness = 0.6,  -- 降低亮度，让非活动 pane 更暗
    }
end

return M
