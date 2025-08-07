-- Theme switching keymaps

-- Theme switching function
local function switch_theme()
  local current_theme = vim.g.colors_name
  
  -- Ensure both themes are available before switching
  local function safe_colorscheme(name)
    local ok, _ = pcall(vim.cmd.colorscheme, name)
    if not ok then
      vim.notify("Theme '" .. name .. "' not available", vim.log.levels.WARN)
      return false
    end
    return true
  end
  
  if current_theme == "nord" then
    if safe_colorscheme("astrodark") then
      vim.notify("Switched to AstroDark theme", vim.log.levels.INFO)
    end
  elseif current_theme == "astrodark" then
    if safe_colorscheme("nord") then
      vim.notify("Switched to Nord theme", vim.log.levels.INFO)
    end
  else
    -- Default fallback
    if safe_colorscheme("nord") then
      vim.notify("Switched to Nord theme (default)", vim.log.levels.INFO)
    end
  end
end

-- Create user command
vim.api.nvim_create_user_command("ToggleTheme", switch_theme, {})

-- Set keybinding
vim.keymap.set("n", "<leader>th", switch_theme, { desc = "Toggle theme between Nord and AstroDark" })