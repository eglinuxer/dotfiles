local wezterm = require("wezterm")

local M = {}

-- Get CPU usage (Linux/macOS)
function M.get_cpu_usage()
    local success, stdout = wezterm.run_child_process({ "sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1 || top -l 1 | grep 'CPU usage' | awk '{print $3}' | cut -d'%' -f1" })
    if success then
        local cpu = tonumber(stdout:match("(%d+%.?%d*)"))
        if cpu then
            return string.format("%.0f%%", cpu)
        end
    end
    return "N/A"
end

-- Get memory usage
function M.get_memory_usage()
    local success, stdout
    -- Try Linux first
    success, stdout = wezterm.run_child_process({ "sh", "-c", "free | grep Mem | awk '{printf \"%.0f%%\", $3/$2 * 100.0}'" })
    if success and stdout ~= "" then
        return stdout:match("(%d+%%)")
    end

    -- Try macOS
    success, stdout = wezterm.run_child_process({ "sh", "-c", "vm_stat | perl -ne '/page size of (\\d+)/ and $size=$1; /Pages active:\\s+(\\d+)/ and $active=$1; /Pages inactive:\\s+(\\d+)/ and $inactive=$1; /Pages speculative:\\s+(\\d+)/ and $spec=$1; /Pages wired down:\\s+(\\d+)/ and $wired=$1; /Pages compressor:\\s+(\\d+)/ and $compr=$1; END { $total=($active+$inactive+$spec+$wired+$compr)*$size/1024/1024/1024; printf \"%.0f%%\", $total/`sysctl -n hw.memsize`*1024/1024/1024*100 }'" })
    if success and stdout ~= "" then
        return stdout:match("(%d+%%)")
    end

    return "N/A"
end

-- Get network status (simplified)
function M.get_network_status()
    local success, stdout = wezterm.run_child_process({ "sh", "-c", "ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1 && echo 'on' || echo 'off'" })
    if success then
        -- Use Nerd Font icons for network status
        return stdout:match("on") and wezterm.nerdfonts.md_wifi or wezterm.nerdfonts.md_wifi_off
    end
    return wezterm.nerdfonts.md_help_network -- Unknown status
end

-- Get load average
function M.get_load_average()
    local success, stdout = wezterm.run_child_process({ "uptime" })
    if success then
        -- Match load average pattern
        local load1, load5, load15 = stdout:match("load%s+averages?:%s+([%d%.]+)[,%s]+([%d%.]+)[,%s]+([%d%.]+)")
        if load1 then
            return string.format("%.2f", tonumber(load1))
        end
    end
    return "N/A"
end

-- Cache for system info to avoid frequent calls
local cache = {
    cpu = { value = "N/A", timestamp = 0 },
    memory = { value = "N/A", timestamp = 0 },
    network = { value = "⚪", timestamp = 0 },
    load = { value = "N/A", timestamp = 0 }
}

local CACHE_DURATION = 5 -- seconds

function M.get_cached_info(info_type, fetch_func)
    local now = os.time()
    local cached = cache[info_type]

    if now - cached.timestamp > CACHE_DURATION then
        cached.value = fetch_func()
        cached.timestamp = now
    end

    return cached.value
end

-- Main function to get all system info
function M.get_system_info()
    return {
        cpu = M.get_cached_info("cpu", M.get_cpu_usage),
        memory = M.get_cached_info("memory", M.get_memory_usage),
        network = M.get_cached_info("network", M.get_network_status),
        load = M.get_cached_info("load", M.get_load_average)
    }
end

return M
