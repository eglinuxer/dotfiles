-- WezTerm 配置框架
-- 支持 macOS, Windows, Linux
-- 作者: eglinux

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- 加载模块
local appearance = require("config.appearance")
local fonts = require("config.fonts")
local keybindings = require("config.keybindings")
local platform_config = require("config.platform")
local ssh = require("config.ssh")
local sessions = require("config.sessions")
local events = require("events")

-- 基础配置
config.initial_cols = 136
config.initial_rows = 38

-- 应用各模块配置
appearance.apply_to_config(config)
fonts.apply_to_config(config)
keybindings.apply_to_config(config)
platform_config.apply_to_config(config)
ssh.apply_to_config(config)
sessions.apply_to_config(config)

-- 设置事件处理
events.setup()

-- 调试模式（开发时可开启）
config.debug_key_events = false

return config
