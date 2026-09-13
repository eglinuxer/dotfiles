-- Bootstrap the plugin manager on first launch.
require("clipboard_setup").setup()
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local output = vim.fn.system {
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  }
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to install lazy.nvim:\n" .. output, vim.log.levels.ERROR)
    return
  end
end
vim.opt.rtp:prepend(lazypath)
if not pcall(require, "lazy") then
  vim.notify("Unable to load lazy.nvim from " .. lazypath, vim.log.levels.ERROR)
  return
end
require "lazy_setup"
require "polish"
