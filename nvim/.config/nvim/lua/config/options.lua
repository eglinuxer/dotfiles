-- Essential Neovim options configuration

local opt = vim.opt

-- General
opt.mouse = "a"                      -- Enable mouse support
opt.clipboard = "unnamedplus"        -- Use system clipboard
opt.undofile = true                  -- Enable persistent undo
opt.updatetime = 300                 -- Faster completion
opt.swapfile = false                 -- Don't create swap files

-- UI
opt.number = true                    -- Show line numbers
opt.relativenumber = true            -- Show relative line numbers
opt.signcolumn = "yes"               -- Always show signcolumn
opt.cursorline = true                -- Highlight current line
opt.wrap = false                     -- Don't wrap lines
opt.scrolloff = 8                    -- Keep 8 lines above/below cursor
opt.splitright = true                -- Split windows to the right
opt.splitbelow = true                -- Split windows below
opt.termguicolors = true             -- Enable 24-bit RGB colors

-- Search
opt.hlsearch = true                  -- Highlight search results
opt.incsearch = true                 -- Incremental search
opt.ignorecase = true                -- Ignore case in search
opt.smartcase = true                 -- Smart case search

-- Indentation
opt.expandtab = true                 -- Use spaces instead of tabs
opt.shiftwidth = 4                   -- Indent width
opt.tabstop = 4                      -- Tab width
opt.smartindent = true               -- Smart indentation
