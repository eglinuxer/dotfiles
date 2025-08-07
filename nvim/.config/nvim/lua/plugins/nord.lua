return {
  "gbprod/nord.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("nord").setup({})
    -- Set as default theme
    vim.cmd.colorscheme("nord")
  end,
}