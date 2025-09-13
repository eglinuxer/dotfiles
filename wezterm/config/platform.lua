local wezterm = require("wezterm")
local platform = require("utils.platform")

local M = {}

function M.apply_to_config(config)
    -- macOS 特定配置
    if platform.is_macos() then
        -- 使用 macOS 原生全屏
        config.native_macos_fullscreen_mode = true

        -- Option 键作为 Alt
        config.send_composed_key_when_left_alt_is_pressed = false
        config.send_composed_key_when_right_alt_is_pressed = false

        -- 默认 shell
        config.default_prog = { "/bin/zsh", "-l" }

        -- 字体微调
        config.font_size = 18

        -- macOS 特定的窗口选项
        config.window_decorations = "TITLE | RESIZE"  -- 显示标题栏和所有按钮

    -- Windows 特定配置
    elseif platform.is_windows() then
        -- 默认使用 PowerShell
        config.default_prog = { "pwsh.exe", "-NoLogo" }

        -- Windows 终端集成
        config.prefer_to_spawn_tabs = false

        -- 字体微调（Windows 渲染不同）
        config.font_size = 16

        -- Windows 11 云母效果
        config.win32_system_backdrop = "Acrylic"

        -- GPU 加速
        config.front_end = "WebGpu"
        config.webgpu_power_preference = "HighPerformance"

    -- Linux 特定配置
    else
        -- 默认 shell
        config.default_prog = { "/bin/zsh", "-l" }

        -- 字体微调
        config.font_size = 17

        -- Wayland 支持
        config.enable_wayland = true

        -- 禁用 IME（如果有输入法问题）
        config.use_ime = true

        -- GPU 加速
        config.front_end = "OpenGL"
    end

    -- 通用性能优化
    config.scrollback_lines = 10000000
    config.enable_kitty_graphics = true

    -- 根据平台调整渲染
    if platform.is_macos() then
        config.front_end = "WebGpu"
        config.webgpu_power_preference = "LowPower" -- macOS 上优先省电
    end
end

return M
