return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    opts.treesitter.auto_install = false
    opts.treesitter.auto_install_cli = false
    -- AstroNvim extends this list; replace it after merging, otherwise its
    -- default parsers are still installed when nvim-treesitter loads.
    opts.treesitter.ensure_installed = {}
    -- Explicit clipboard registers only; ordinary y/d/c remain internal.
    opts.options.opt.clipboard = ""
    for _, key in ipairs { "<C-H>", "<C-J>", "<C-K>", "<C-L>" } do opts.mappings.t[key] = false end
  end,
}
