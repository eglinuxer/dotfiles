local function check(value, message) assert(value, message) end
vim.wait(1000, function() return package.loaded.astrocore ~= nil end)
check(vim.opt.clipboard:get()[1] == nil, 'clipboard must not link ordinary registers')
local ts = require('astrocore').config.treesitter
check(not ts.auto_install and not ts.auto_install_cli and #ts.ensure_installed == 0, 'parser installation must be explicit')
check(require('lazy.core.config').options.install.missing == true, 'missing plugins must install automatically')
local ss = require('smart-splits')
local cfg = require('smart-splits.config')
check(cfg.multiplexer_integration == false, 'multiplexer must be disabled')
check(cfg.at_edge == 'stop', 'edge must stop')
for _, key in ipairs { '<C-H>', '<NL>', '<C-K>', '<C-L>' } do
  check(next(vim.fn.maparg(key, 't', false, true)) == nil, 'terminal key intercepted: '..key)
  check(next(vim.fn.maparg(key, 'n', false, true)) ~= nil, 'normal navigation missing: '..key)
end
vim.cmd.vsplit()
local right = vim.api.nvim_get_current_win()
ss.move_cursor_right()
check(vim.api.nvim_get_current_win() == right, 'edge navigation wrapped')
ss.move_cursor_left()
check(vim.api.nvim_get_current_win() ~= right, 'internal navigation failed')
-- A deterministic fake desktop provider proves ordinary deletes do not write it.
local writes = 0
vim.g.clipboard = { name = 'test', copy = { ['+'] = function() writes=writes+1 end, ['*'] = function() writes=writes+1 end }, paste = { ['+'] = function() return {{'desktop'}, 'v'} end, ['*'] = function() return {{'desktop'}, 'v'} end } }
vim.api.nvim_buf_set_lines(0, 0, -1, false, {'delete me', 'copy me'})
vim.cmd('normal! ggdd')
check(writes == 0, 'ordinary delete wrote desktop')
vim.cmd('normal! "+yy')
check(writes == 1, 'explicit yank did not write desktop')
check(vim.g.colors_name == 'catppuccin', 'unexpected theme')
check(vim.api.nvim_get_hl(0, { name = 'Normal' }).bg == 0x1e1e2e, 'expected Mocha background')
print('PASS: AstroNvim merged options, terminal maps, split boundary, clipboard isolation, theme')
vim.cmd('qa!')
