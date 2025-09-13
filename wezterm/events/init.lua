local wezterm = require("wezterm")
local tab_title = require("events.tab_title")
local status_bar = require("events.status_bar")
local background_switcher = require("events.background_switcher")

local M = {}

function M.setup()
    -- 设置标签页标题格式化
    tab_title.setup()

    -- 设置状态栏更新
    status_bar.setup()

    -- 设置背景切换功能
    background_switcher.setup()

    -- 窗口配置改变时的处理
    wezterm.on("window-config-reloaded", function(window, pane)
        wezterm.log_info("Configuration reloaded!")
    end)
end

return M
