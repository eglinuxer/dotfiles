local wezterm = require("wezterm")
local act = wezterm.action
local platform = require("utils.platform")

local M = {}

-- 获取修饰键（跨平台兼容）
local function get_mod()
    if platform.is_macos() then
        return "CMD"
    else
        return "CTRL|SHIFT"
    end
end

local mod = get_mod()

function M.apply_to_config(config)
    -- 禁用默认键位，避免与 tmux/neovim 冲突
    config.disable_default_key_bindings = false

    -- Leader key (类似 tmux，但使用不同的组合避免冲突)
    config.leader = { key = "e", mods = "CTRL", timeout_milliseconds = 1000 }

    config.keys = {
        -- === 与 tmux 兼容的键位 ===
        -- 使用 LEADER 前缀，避免与 tmux 的 C-b 冲突

        -- 分屏（类似 tmux）
        { key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
        { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

        -- 面板导航（使用 vim 风格，与 AstroNvim 一致）
        { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
        { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
        { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
        { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

        -- 面板大小调整（使用 Alt+箭头）
        { key = "LeftArrow", mods = "ALT", action = act.AdjustPaneSize({ "Left", 1 }) },
        { key = "RightArrow", mods = "ALT", action = act.AdjustPaneSize({ "Right", 1 }) },
        { key = "UpArrow", mods = "ALT", action = act.AdjustPaneSize({ "Up", 1 }) },
        { key = "DownArrow", mods = "ALT", action = act.AdjustPaneSize({ "Down", 1 }) },

        -- 关闭面板
        { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },

        -- 面板缩放（类似 tmux 的 zoom）
        { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

        -- === 标签页管理 ===
        -- 新建标签页
        { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },

        -- 标签页导航（数字键）
        { key = "1", mods = "LEADER", action = act.ActivateTab(0) },
        { key = "2", mods = "LEADER", action = act.ActivateTab(1) },
        { key = "3", mods = "LEADER", action = act.ActivateTab(2) },
        { key = "4", mods = "LEADER", action = act.ActivateTab(3) },
        { key = "5", mods = "LEADER", action = act.ActivateTab(4) },
        { key = "6", mods = "LEADER", action = act.ActivateTab(5) },
        { key = "7", mods = "LEADER", action = act.ActivateTab(6) },
        { key = "8", mods = "LEADER", action = act.ActivateTab(7) },
        { key = "9", mods = "LEADER", action = act.ActivateTab(8) },

        -- 切换标签页
        { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
        { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },

        -- 重命名标签页
        { key = ",", mods = "LEADER", action = act.PromptInputLine({
            description = "Enter new name for tab",
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    window:active_tab():set_title(line)
                end
            end),
        })},

        -- === 工作区管理 ===
        -- 切换工作区
        { key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },

        -- 创建新工作区
        { key = "W", mods = "LEADER|SHIFT", action = act.PromptInputLine({
            description = "Enter name for new workspace",
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    window:perform_action(
                        act.SwitchToWorkspace({
                            name = line,
                        }),
                        pane
                    )
                end
            end),
        })},

        -- === SSH 连接管理 ===
        { key = "s", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|DOMAINS" }) },

        -- === 复制模式（类似 vim） ===
        { key = "[", mods = "LEADER", action = act.ActivateCopyMode },

        -- === 搜索 ===
        { key = "/", mods = "LEADER", action = act.Search({ CaseSensitiveString = "" }) },

        -- === 命令面板 ===
        { key = ":", mods = "LEADER|SHIFT", action = act.ActivateCommandPalette },

        -- === 主题切换 ===
        { key = "t", mods = "LEADER", action = wezterm.action_callback(function(window, pane)
            -- 切换主题
            local overrides = window:get_config_overrides() or {}
            local appearance = require("config.appearance")

            if not overrides.color_scheme or overrides.color_scheme == appearance.themes["tokyo-night"] then
                overrides.color_scheme = appearance.themes["nord"]
            else
                overrides.color_scheme = appearance.themes["tokyo-night"]
            end

            window:set_config_overrides(overrides)
        end)},

        -- === 背景图片切换 ===
        { key = "b", mods = "LEADER", action = act.EmitEvent("switch-background") },
        { key = "B", mods = "LEADER|SHIFT", action = act.EmitEvent("switch-background-prev") },
        { key = "?", mods = "LEADER|SHIFT", action = act.EmitEvent("switch-background-random") },

        -- === 快速操作（不需要 Leader） ===
        -- 字体大小调整
        { key = "+", mods = mod, action = act.IncreaseFontSize },
        { key = "-", mods = mod, action = act.DecreaseFontSize },
        { key = "0", mods = mod, action = act.ResetFontSize },

        -- 全屏
        { key = "Enter", mods = "ALT", action = act.ToggleFullScreen },

        -- 复制粘贴（跨平台）
        { key = "c", mods = mod, action = act.CopyTo("Clipboard") },
        { key = "v", mods = mod, action = act.PasteFrom("Clipboard") },

        -- 清屏
        { key = "k", mods = "CMD", action = act.ClearScrollback("ScrollbackAndViewport") },

        -- 重载配置
        { key = "r", mods = "LEADER", action = act.ReloadConfiguration },

        -- 显示调试信息
        { key = "d", mods = "LEADER", action = act.ShowDebugOverlay },
    }

    -- 鼠标绑定
    config.mouse_bindings = {
        -- 右键粘贴
        {
            event = { Down = { streak = 1, button = "Right" } },
            mods = "NONE",
            action = act.PasteFrom("PrimarySelection"),
        },
        -- Ctrl+Click 打开链接
        {
            event = { Up = { streak = 1, button = "Left" } },
            mods = "CTRL",
            action = act.OpenLinkAtMouseCursor,
        },
    }
end

return M
