-- Theme switching function
local function switch_theme()
  local current_theme = vim.g.colors_name
  if current_theme == "nord" then
    vim.cmd.colorscheme("astrodark")
    print("Switched to AstroDark theme")
  elseif current_theme == "astrodark" then
    vim.cmd.colorscheme("nord")
    print("Switched to Nord theme")
  else
    vim.cmd.colorscheme("nord")
    print("Switched to Nord theme")
  end
end

-- Create user command
vim.api.nvim_create_user_command("ToggleTheme", switch_theme, {})

-- Set keybinding
vim.keymap.set("n", "<leader>th", switch_theme, { desc = "Toggle theme between Nord and AstroDark" })