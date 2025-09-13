local wezterm = require("wezterm")

local M = {}

function M.apply_to_config(config)
    -- 主字体
    config.font = wezterm.font_with_fallback({
        {
            family = "0xProto Nerd Font Mono",
            weight = "Regular",
        },
        "JetBrains Mono",
        "Cascadia Code",
        "Fira Code",
        "Consolas",
    })

    -- 字体大小
    config.font_size = 14

    -- 状态栏和标签栏字体大小（仅适用于 fancy tab bar）
    -- 注意：这会让标签栏和状态栏使用更大的字体
    config.window_frame = {
        font = wezterm.font({ family = "0xProto Nerd Font Mono", weight = "Bold" }),
        font_size = 13.0,  -- 增大状态栏字体
        active_titlebar_bg = "#1a1b26",
        inactive_titlebar_bg = "#1a1b26",
    }

    -- 行高
    config.line_height = 1.2

    -- 字体渲染
    config.freetype_load_target = "Light"
    config.freetype_render_target = "HorizontalLcd"

    -- 针对不同语言的字体规则
    config.font_rules = {
        -- 斜体
        {
            italic = true,
            font = wezterm.font({
                family = "0xProto Nerd Font Mono",
                style = "Italic",
            }),
        },
        -- 粗体
        {
            intensity = "Bold",
            font = wezterm.font({
                family = "0xProto Nerd Font Mono",
                weight = "Bold",
            }),
        },
        -- 粗斜体
        {
            italic = true,
            intensity = "Bold",
            font = wezterm.font({
                family = "0xProto Nerd Font Mono",
                weight = "Bold",
                style = "Italic",
            }),
        },
    }

    -- 启用连字
    config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
end

return M
