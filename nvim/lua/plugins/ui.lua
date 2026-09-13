return {
  {
    "mason-org/mason.nvim",
    -- Match Lazy/Snacks: do not dim the canvas behind a transparent panel.
    opts = { ui = { backdrop = 100, border = "rounded" } },
  },
  {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
      local status = require "astroui.status"
      opts.statusline = {
        hl = { fg = "fg", bg = "bg" },
        status.component.mode {
          mode_text = { padding = { left = 1, right = 1 } },
        },
        status.component.git_branch(),
        status.component.file_info(),
        status.component.git_diff(),
        status.component.diagnostics(),
        status.component.fill(),
        status.component.cmd_info(),
        status.component.nav { scrollbar = false, padding = { left = 1, right = 1 } },
      }
    end,
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        layout = {
          preset = function() return vim.o.columns >= 140 and "dotfiles_wide" or "dotfiles_compact" end,
        },
        layouts = {
          dotfiles_wide = {
            layout = {
              box = "horizontal", width = 0.9, height = 0.8, backdrop = false,
              {
                box = "vertical", border = "rounded", title = " {title} {live} {flags} ", title_pos = "left",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
              },
              { win = "preview", title = " {preview} ", border = "rounded", width = 0.5 },
            },
          },
          dotfiles_compact = {
            hidden = { "preview" },
            layout = {
              box = "vertical", width = 0.95, height = 0.7, backdrop = false,
              border = "rounded", title = " {title} {live} {flags} ", title_pos = "left",
              { win = "input", height = 1, border = "bottom" },
              { win = "list", border = "none" },
              { win = "preview", title = " {preview} ", height = 0.4, border = "top" },
            },
          },
        },
      },
      input = { win = { border = "rounded", title_pos = "left" } },
      notifier = { style = "compact", margin = { top = 1, right = 1, bottom = 0 } },
      styles = { notification = { border = "rounded" } },
    },
  },
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = { border = "rounded" },
        documentation = { auto_show_delay_ms = 200, window = { border = "rounded" } },
      },
      signature = { window = { border = "rounded" } },
    },
  },
}
