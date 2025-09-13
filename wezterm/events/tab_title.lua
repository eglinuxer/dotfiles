local wezterm = require("wezterm")

local M = {}

-- Get the basename of the running process
local function get_process_name(pane)
    local process_name = pane.foreground_process_name
    if not process_name then
        return "shell"
    end

    -- Extract just the program name from the full path
    local name = process_name:match("([^/\\]+)$") or process_name

    -- Remove arguments if present
    name = name:match("^([^%s]+)") or name

    -- Map common shells to "shell"
    if name == "bash" or name == "zsh" or name == "fish" or name == "sh" then
        return "shell"
    end

    return name
end

-- Get icon for the process
local function get_process_icon(process_name)
    local icons = {
        ["nvim"] = wezterm.nerdfonts.dev_vim,
        ["vim"] = wezterm.nerdfonts.dev_vim,
        ["vi"] = wezterm.nerdfonts.dev_vim,
        ["emacs"] = wezterm.nerdfonts.custom_emacs,
        ["nano"] = wezterm.nerdfonts.md_note_edit,
        ["code"] = wezterm.nerdfonts.md_microsoft_visual_studio_code,
        ["python"] = wezterm.nerdfonts.dev_python,
        ["python3"] = wezterm.nerdfonts.dev_python,
        ["node"] = wezterm.nerdfonts.md_nodejs,
        ["npm"] = wezterm.nerdfonts.md_npm,
        ["yarn"] = wezterm.nerdfonts.seti_yarn,
        ["pnpm"] = wezterm.nerdfonts.md_npm_variant,
        ["cargo"] = wezterm.nerdfonts.dev_rust,
        ["rustc"] = wezterm.nerdfonts.dev_rust,
        ["gcc"] = wezterm.nerdfonts.custom_c,
        ["g++"] = wezterm.nerdfonts.custom_cpp,
        ["clang"] = wezterm.nerdfonts.custom_c,
        ["make"] = wezterm.nerdfonts.cod_tools,
        ["cmake"] = wezterm.nerdfonts.cod_tools,
        ["git"] = wezterm.nerdfonts.dev_git,
        ["docker"] = wezterm.nerdfonts.linux_docker,
        ["kubectl"] = wezterm.nerdfonts.md_kubernetes,
        ["terraform"] = wezterm.nerdfonts.md_terraform,
        ["ssh"] = wezterm.nerdfonts.md_server,
        ["tmux"] = wezterm.nerdfonts.cod_terminal_tmux,
        ["htop"] = wezterm.nerdfonts.md_monitor,
        ["btop"] = wezterm.nerdfonts.md_monitor,
        ["top"] = wezterm.nerdfonts.md_monitor,
        ["less"] = wezterm.nerdfonts.md_file_document,
        ["more"] = wezterm.nerdfonts.md_file_document,
        ["cat"] = wezterm.nerdfonts.md_file_document,
        ["bat"] = wezterm.nerdfonts.md_file_document,
        ["man"] = wezterm.nerdfonts.md_book_open,
        ["curl"] = wezterm.nerdfonts.md_download,
        ["wget"] = wezterm.nerdfonts.md_download,
        ["mysql"] = wezterm.nerdfonts.dev_mysql,
        ["psql"] = wezterm.nerdfonts.dev_postgresql,
        ["redis-cli"] = wezterm.nerdfonts.dev_redis,
        ["mongosh"] = wezterm.nerdfonts.dev_mongodb,
        ["shell"] = wezterm.nerdfonts.cod_terminal,
        ["bash"] = wezterm.nerdfonts.cod_terminal,
        ["zsh"] = wezterm.nerdfonts.cod_terminal,
        ["fish"] = wezterm.nerdfonts.md_fish,
        ["lua"] = wezterm.nerdfonts.seti_lua,
        ["ruby"] = wezterm.nerdfonts.dev_ruby,
        ["go"] = wezterm.nerdfonts.md_language_go,
        ["java"] = wezterm.nerdfonts.dev_java,
        ["javac"] = wezterm.nerdfonts.dev_java,
    }

    return icons[process_name] or wezterm.nerdfonts.cod_terminal
end

function M.setup()
    wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
        local pane = tab.active_pane

        -- Get the running process name
        local process_name = get_process_name(pane)
        local icon = get_process_icon(process_name)

        -- Format the process name for display
        local title = process_name
        if process_name == "shell" then
            -- For shell, just show "Terminal"
            title = "Terminal"
        else
            -- Capitalize first letter for other programs
            title = title:sub(1,1):upper() .. title:sub(2)
        end

        -- Add icon to title
        title = icon .. " " .. title

        -- Truncate if too long
        if #title > 25 then
            title = string.sub(title, 1, 23) .. "..."
        end

        -- 标签索引
        local index = tab.tab_index + 1

        -- 构建标签内容
        local elements = {}

        -- 左边界
        if tab.is_active then
            table.insert(elements, { Background = { Color = "#7aa2f7" } })
            table.insert(elements, { Foreground = { Color = "#1e2030" } })
        else
            table.insert(elements, { Background = { Color = "#3b4261" } })
            table.insert(elements, { Foreground = { Color = "#c0caf5" } })
        end

        -- 标签内容
        if tab.is_active then
            -- 活动标签：更突出的样式
            table.insert(elements, { Text = " " })
            table.insert(elements, { Text = string.format("%d:", index) })
            table.insert(elements, { Attribute = { Intensity = "Bold" } })
            table.insert(elements, { Text = title })
            table.insert(elements, { Attribute = { Intensity = "Normal" } })
            table.insert(elements, { Text = " " })
        else
            -- 非活动标签
            table.insert(elements, { Text = string.format(" %d:%s ", index, title) })
        end

        -- 添加关闭按钮提示（如果有多个标签）
        if #tabs > 1 then
            if tab.is_active then
                table.insert(elements, { Text = "× " })
            end
        end

        return elements
    end)
end

return M
