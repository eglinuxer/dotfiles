local wezterm = require("wezterm")
local system_info = require("utils.system_info")

local M = {}

-- Powerline 符号
local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider -- ""
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider -- ""

function M.setup()
    wezterm.on("update-status", function(window, pane)
        -- 构建状态栏元素
        local elements = {}

        -- 获取当前工作区
        local workspace = window:active_workspace()

        -- 获取当前时间
        local date = wezterm.strftime("%H:%M:%S")

        -- 获取系统信息
        local sys_info = system_info.get_system_info()

        -- 获取电池状态
        local battery_info = ""
        for _, b in ipairs(wezterm.battery_info()) do
            battery_info = string.format("%.0f%%", b.state_of_charge * 100)
        end

        -- 右侧状态栏使用 Powerline 风格
        -- 使用 Nord 主题配色方案

        -- 设置更大的字体（状态栏全局）
        table.insert(elements, { Attribute = { Intensity = "Bold" } })

        -- 从标签栏背景开始过渡
        table.insert(elements, { Background = { Color = "#1a1b26" } }) -- 保持标签栏背景色
        table.insert(elements, { Foreground = { Color = "#2e3440" } }) -- Nord0 最深色
        table.insert(elements, { Text = SOLID_RIGHT_ARROW })

        -- 工作区部分 - Nord1
        table.insert(elements, { Background = { Color = "#2e3440" } }) -- Nord0
        table.insert(elements, { Foreground = { Color = "#8fbcbb" } }) -- Nord7 青色
        table.insert(elements, { Text = " " .. wezterm.nerdfonts.cod_window .. " " }) -- 
        table.insert(elements, { Foreground = { Color = "#eceff4" } }) -- Nord6 亮白
        table.insert(elements, { Text = workspace .. " " })

        -- 系统信息部分过渡
        table.insert(elements, { Background = { Color = "#2e3440" } })
        table.insert(elements, { Foreground = { Color = "#3b4252" } }) -- Nord1
        table.insert(elements, { Text = SOLID_RIGHT_ARROW })

        -- CPU 信息
        table.insert(elements, { Background = { Color = "#3b4252" } }) -- Nord1
        table.insert(elements, { Foreground = { Color = "#88c0d0" } }) -- Nord8 cyan
        table.insert(elements, { Text = " " .. wezterm.nerdfonts.md_cpu_64_bit .. " " }) --  or 
        table.insert(elements, { Foreground = { Color = "#e5e9f0" } }) -- Nord5
        table.insert(elements, { Text = sys_info.cpu .. " " })

        -- Memory 信息
        table.insert(elements, { Foreground = { Color = "#81a1c1" } }) -- Nord9 light blue
        table.insert(elements, { Text = wezterm.nerdfonts.md_memory .. " " }) -- 
        table.insert(elements, { Foreground = { Color = "#e5e9f0" } }) -- Nord5
        table.insert(elements, { Text = sys_info.memory .. " " })

        -- Network 状态
        table.insert(elements, { Foreground = { Color = "#d8dee9" } }) -- Nord4
        table.insert(elements, { Text = sys_info.network .. " " })

        -- 时间部分过渡
        table.insert(elements, { Background = { Color = "#3b4252" } })
        table.insert(elements, { Foreground = { Color = "#434c5e" } }) -- Nord2
        table.insert(elements, { Text = SOLID_RIGHT_ARROW })

        -- 时间显示
        table.insert(elements, { Background = { Color = "#434c5e" } }) -- Nord2
        table.insert(elements, { Foreground = { Color = "#b48ead" } }) -- Nord15 紫色
        table.insert(elements, { Text = " " .. wezterm.nerdfonts.md_clock_time_three .. " " }) --  or 
        table.insert(elements, { Foreground = { Color = "#e5e9f0" } }) -- Nord5
        table.insert(elements, { Text = date .. " " })

        -- 电池部分（如果有）
        if battery_info ~= "" then
            table.insert(elements, { Background = { Color = "#434c5e" } })
            table.insert(elements, { Foreground = { Color = "#4c566a" } }) -- Nord3
            table.insert(elements, { Text = SOLID_RIGHT_ARROW })

            -- 根据电量显示不同颜色 (Nord 颜色)
            local battery_percent = tonumber(battery_info:match("(%d+)"))
            local battery_color = "#a3be8c" -- Nord14 绿色
            if battery_percent and battery_percent < 20 then
                battery_color = "#bf616a" -- Nord11 红色
            elseif battery_percent and battery_percent < 50 then
                battery_color = "#ebcb8b" -- Nord13 黄色
            end

            table.insert(elements, { Background = { Color = "#4c566a" } }) -- Nord3
            table.insert(elements, { Foreground = { Color = battery_color } })
            -- Choose battery icon based on percentage
            local battery_icon = wezterm.nerdfonts.md_battery
            if battery_percent then
                if battery_percent >= 90 then
                    battery_icon = wezterm.nerdfonts.md_battery -- full
                elseif battery_percent >= 70 then
                    battery_icon = wezterm.nerdfonts.md_battery_80 -- 80%
                elseif battery_percent >= 50 then
                    battery_icon = wezterm.nerdfonts.md_battery_60 -- 60%
                elseif battery_percent >= 30 then
                    battery_icon = wezterm.nerdfonts.md_battery_40 -- 40%
                elseif battery_percent >= 10 then
                    battery_icon = wezterm.nerdfonts.md_battery_20 -- 20%
                else
                    battery_icon = wezterm.nerdfonts.md_battery_alert -- alert
                end
            end
            table.insert(elements, { Text = " " .. battery_icon .. " " })
            table.insert(elements, { Foreground = { Color = "#d8dee9" } }) -- Nord4
            table.insert(elements, { Text = battery_info .. " " })
        end

        -- 设置状态栏
        window:set_right_status(wezterm.format(elements))

        -- 左侧状态栏（可选，显示一些额外信息）
        local left_elements = {}

        -- 获取当前域信息
        local domain = pane:get_domain_name()
        if domain ~= "local" then
            -- SSH 连接指示器 - 使用 Nord 颜色
            table.insert(left_elements, { Background = { Color = "#88c0d0" } }) -- Nord8 亮青色
            table.insert(left_elements, { Foreground = { Color = "#2e3440" } }) -- Nord0
            table.insert(left_elements, { Text = " " .. wezterm.nerdfonts.md_server_network .. " " }) --  or 
            table.insert(left_elements, { Attribute = { Intensity = "Bold" } })
            table.insert(left_elements, { Text = domain })
            table.insert(left_elements, { Attribute = { Intensity = "Normal" } })
            table.insert(left_elements, { Text = " " })

            table.insert(left_elements, { Background = { Color = "#1a1b26" } })
            table.insert(left_elements, { Foreground = { Color = "#88c0d0" } }) -- Nord8
            table.insert(left_elements, { Text = SOLID_LEFT_ARROW })
        end

        window:set_left_status(wezterm.format(left_elements))
    end)
end

return M
