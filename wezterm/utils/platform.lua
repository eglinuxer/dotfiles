local wezterm = require("wezterm")

local M = {}

-- 检测操作系统
function M.is_windows()
    return wezterm.target_triple:find("windows") ~= nil
end

function M.is_macos()
    return wezterm.target_triple:find("darwin") ~= nil
end

function M.is_linux()
    return wezterm.target_triple:find("linux") ~= nil
end

-- 获取平台名称
function M.get_platform()
    if M.is_windows() then
        return "windows"
    elseif M.is_macos() then
        return "macos"
    else
        return "linux"
    end
end

-- 获取默认 shell
function M.get_default_shell()
    if M.is_windows() then
        return "pwsh.exe"
    else
        return "/bin/zsh"
    end
end

-- 获取 home 目录
function M.get_home()
    if M.is_windows() then
        return os.getenv("USERPROFILE")
    else
        return os.getenv("HOME")
    end
end

-- 路径分隔符
function M.path_separator()
    if M.is_windows() then
        return "\\"
    else
        return "/"
    end
end

return M