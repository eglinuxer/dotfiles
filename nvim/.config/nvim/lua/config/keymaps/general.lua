-- General keymaps for common operations

-- Save file
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Quit Neovim
vim.keymap.set("n", "<C-q>", "<cmd>qa<cr>", { desc = "Quit Neovim" })