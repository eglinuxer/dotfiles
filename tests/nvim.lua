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
require('lazy').load { plugins = { 'heirline.nvim', 'neo-tree.nvim', 'snacks.nvim', 'blink.cmp' } }
local function check_backgrounds()
  for _, name in ipairs {
    'Normal', 'NormalNC', 'WinSeparator', 'SignColumn', 'LineNr', 'EndOfBuffer', 'FoldColumn',
    'StatusLine', 'StatusLineNC', 'StatusLineTerm', 'StatusLineTermNC', 'TabLine', 'TabLineFill', 'WinBar', 'WinBarNC',
    'NeoTreeNormal', 'NeoTreeNormalNC', 'NeoTreeTabInactive', 'NeoTreeTabSeparatorInactive', 'NeoTreeTitleBar',
    'NormalFloat', 'FloatBorder', 'FloatTitle', 'FloatFooter', 'Pmenu', 'PmenuExtra', 'PmenuSbar',
    'SnacksPicker', 'SnacksNormalNC', 'SnacksInputNormal', 'BlinkCmpMenu', 'BlinkCmpDoc',
  } do
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    check(hl.bg == nil and hl.ctermbg == nil, 'opaque structural background: ' .. name)
  end
  check(vim.api.nvim_get_hl(0, { name = 'PmenuSel', link = false }).bg == 0x45475a, 'selection background lost')
  local colors = require('heirline.highlights').get_loaded_colors()
  check(colors.bg == 'NONE' and colors.tabline_bg == 'NONE', 'status/tabline canvas must inherit terminal')
  check(colors.buffer_bg == 'NONE' and colors.buffer_visible_bg == 'NONE', 'inactive buffer tabs must inherit terminal')
  check(colors.file_info_bg == '#313244' and colors.normal == '#cba6f7', 'rounded modules must retain their colors')
  check(colors.mode_fg == '#11111b', 'mode text must remain readable on colored segments')
end
check_backgrounds()
for _ = 1, 2 do
  vim.cmd.colorscheme('catppuccin')
  check_backgrounds()
end
dofile('tests/nvim-surfaces.lua')
print('PASS: AstroNvim options, navigation, clipboard, transparent canvas, floating panels and theme reload')
vim.cmd('qa!')
