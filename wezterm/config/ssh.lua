local wezterm = require("wezterm")
local platform = require("utils.platform")

local M = {}

function M.apply_to_config(config)
    -- SSH 域配置
    config.ssh_domains = {}

    -- 可以在这里添加常用的 SSH 连接
    -- 示例配置：
    --[[
    config.ssh_domains = {
        {
            name = "my-server",
            remote_address = "192.168.1.100",
            username = "user",
            -- 可选：指定私钥
            -- ssh_option = {
            --     identityfile = "/path/to/key",
            -- },
        },
    }
    --]]

    -- WSL 域（仅 Windows）
    if platform.is_windows() then
        config.wsl_domains = {
            {
                name = "WSL:Ubuntu",
                distribution = "Ubuntu",
                default_cwd = "~",
            },
        }
    end

    -- 默认域
    config.default_domain = "local"
end

return M
