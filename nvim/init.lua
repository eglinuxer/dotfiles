-- Installation is explicit (README.md); startup never clones dependencies.
require("clipboard_setup").setup()
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.notify("lazy.nvim is missing. Follow dotfiles README installation instructions.", vim.log.levels.ERROR)
  return
end
vim.opt.rtp:prepend(lazypath)
if not pcall(require, "lazy") then
  vim.notify("Unable to load lazy.nvim from " .. lazypath, vim.log.levels.ERROR)
  return
end
require "lazy_setup"
require "polish"
