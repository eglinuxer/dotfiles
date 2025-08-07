-- Window navigation and management keymaps

-- Window navigation with smart-splits
vim.keymap.set("n", "<C-h>", function()
  require("smart-splits").move_cursor_left()
end, { desc = "Move to left window" })

vim.keymap.set("n", "<C-j>", function()
  require("smart-splits").move_cursor_down()
end, { desc = "Move to down window" })

vim.keymap.set("n", "<C-k>", function()
  require("smart-splits").move_cursor_up()
end, { desc = "Move to up window" })

vim.keymap.set("n", "<C-l>", function()
  require("smart-splits").move_cursor_right()
end, { desc = "Move to right window" })

-- Window resizing
vim.keymap.set("n", "<C-Up>", function()
  require("smart-splits").resize_up()
end, { desc = "Resize window up" })

vim.keymap.set("n", "<C-Down>", function()
  require("smart-splits").resize_down()
end, { desc = "Resize window down" })

vim.keymap.set("n", "<C-Left>", function()
  require("smart-splits").resize_left()
end, { desc = "Resize window left" })

vim.keymap.set("n", "<C-Right>", function()
  require("smart-splits").resize_right()
end, { desc = "Resize window right" })

-- Resize mode toggle
vim.keymap.set("n", "<leader>r", function()
  require("smart-splits").start_resize_mode()
end, { desc = "Enter resize mode" })

-- Window splits
vim.keymap.set("n", "<leader>\\", "<cmd>vsplit<cr>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>-", "<cmd>split<cr>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>c", "<cmd>close<cr>", { desc = "Close current window" })
vim.keymap.set("n", "<leader>so", "<cmd>only<cr>", { desc = "Close all other windows" })