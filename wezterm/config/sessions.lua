local wezterm = require("wezterm")
local platform = require("utils.platform")

local M = {}

function M.apply_to_config(config)
    -- 退出行为：Close 直接关闭，Hold 保持窗口，CloseOnCleanExit 仅在正常退出时关闭
    config.exit_behavior = "Close"

    -- 窗口关闭行为：NeverPrompt 不提示，AlwaysPrompt 总是提示
    config.window_close_confirmation = "NeverPrompt"

    -- 启动时的行为
    config.default_prog = nil -- 使用系统默认 shell

    -- 设置默认工作目录
    local home = platform.get_home()
    config.default_cwd = home

    -- 定义启动菜单（快速启动不同的配置）
    config.launch_menu = {}

    -- macOS/Linux 启动菜单
    if not platform.is_windows() then
        table.insert(config.launch_menu, {
            label = "Bash",
            args = { "/bin/bash", "-l" },
        })
        table.insert(config.launch_menu, {
            label = "Zsh",
            args = { "/bin/zsh", "-l" },
        })
        if platform.is_macos() then
            table.insert(config.launch_menu, {
                label = "Fish",
                args = { "/opt/homebrew/bin/fish", "-l" },
            })
        end
    else
        -- Windows 启动菜单
        table.insert(config.launch_menu, {
            label = "PowerShell",
            args = { "pwsh.exe", "-NoLogo" },
        })
        table.insert(config.launch_menu, {
            label = "Command Prompt",
            args = { "cmd.exe" },
        })
        table.insert(config.launch_menu, {
            label = "Git Bash",
            args = { "C:\\Program Files\\Git\\bin\\bash.exe", "-l" },
        })
    end
end

return M
