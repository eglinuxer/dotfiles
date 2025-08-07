return {
  "AstroNvim/astrotheme",
  lazy = false,
  priority = 999,
  config = function()
    require("astrotheme").setup({})
    -- Don't set as default, just ensure it's loaded
  end,
}