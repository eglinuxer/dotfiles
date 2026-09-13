return {
  "AstroNvim/astroui",
  opts = {
    -- Neovim 0.12 ships Catppuccin: dark background selects Mocha.
    colorscheme = "catppuccin",
    highlights = {
      catppuccin = {
        NormalFloat = { fg = "#cdd6f4", bg = "#181825" },
        FloatBorder = { fg = "#585b70", bg = "#181825" },
        FloatTitle = { fg = "#b4befe", bg = "#181825", bold = true },
        WinSeparator = { fg = "#45475a", bg = "#1e1e2e" },
        Pmenu = { fg = "#cdd6f4", bg = "#181825" },
        PmenuSel = { fg = "#cdd6f4", bg = "#45475a", bold = true },
        SnacksPickerMatch = { fg = "#b4befe", bold = true },
        SnacksPickerBorder = { link = "FloatBorder" },
        SnacksPickerTitle = { link = "FloatTitle" },
        SnacksInputNormal = { link = "NormalFloat" },
        SnacksInputBorder = { link = "FloatBorder" },
        SnacksInputTitle = { link = "FloatTitle" },
      },
    },
    status = {
      -- Rounded segments are part of the user's theme, including after reloads.
      separators = { left = { "", "" }, right = { "", "" }, center = { "", "" } },
      colors = {
        fg = "#cdd6f4", bg = "#181825",
        normal = "#cba6f7", insert = "#a6e3a1", visual = "#cba6f7",
        replace = "#f38ba8", command = "#f9e2af", terminal = "#94e2d5",
        git_branch_fg = "#cdd6f4", git_branch_bg = "#313244",
        file_info_bg = "#313244", nav_bg = "#313244",
        tabline_bg = "#181825", buffer_active_bg = "#313244",
        buffer_active_fg = "#b4befe", buffer_visible_bg = "#1e1e2e",
        buffer_visible_fg = "#cdd6f4", buffer_bg = "#181825", buffer_fg = "#a6adc8",
      },
    },
  },
}
