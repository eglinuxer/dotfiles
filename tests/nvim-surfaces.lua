-- Instantiate lazy-loaded UI surfaces; checking only startup highlights misses
-- generated Neo-tree tabs and Snacks layout-box backgrounds.
require('lazy').load { plugins = { 'neo-tree.nvim', 'snacks.nvim', 'mason.nvim', 'which-key.nvim' } }
local canvas = {
  Normal = true, NormalNC = true, NormalFloat = true, FloatBorder = true,
  FloatTitle = true, FloatFooter = true, WinSeparator = true, SignColumn = true,
  EndOfBuffer = true, StatusLine = true, StatusLineNC = true, WinBar = true, WinBarNC = true,
}
local function check_windows()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    for source, target in vim.wo[win].winhighlight:gmatch('([^,:]+):([^,]+)') do
      if canvas[source] then
        assert(vim.fn.hlexists(target) == 1, 'uninitialized window highlight: ' .. target)
        local hl = vim.api.nvim_get_hl(0, { name = target, link = false })
        assert(not hl.bg and not hl.ctermbg, 'opaque window surface: ' .. target)
      end
    end
  end
end
local old_columns, old_lines = vim.o.columns, vim.o.lines
vim.o.lines = 50
vim.cmd('Neotree show')
check_windows()
for _, columns in ipairs { 120, 160 } do
  vim.o.columns = columns
  local picker = Snacks.picker {
    items = { { text = 'tests/nvim.lua', file = vim.fn.getcwd() .. '/tests/nvim.lua' } },
    format = 'file', preview = 'file',
  }
  assert(vim.wait(1000, function()
    return picker.input.win.win and vim.api.nvim_win_is_valid(picker.input.win.win)
  end), 'picker input did not open')
  if columns < 140 then picker:toggle('preview') end
  assert(vim.wait(1000, function()
    return picker.preview.win.win and vim.api.nvim_win_is_valid(picker.preview.win.win)
  end), 'picker preview did not open')
  check_windows()
  vim.cmd.colorscheme('catppuccin')
  check_windows()
  picker:close()
  -- Snacks releases picker references before its scheduled window cleanup.
  -- Drain that cleanup before the next VimResized event.
  local settled = false
  vim.schedule(function() settled = true end)
  assert(vim.wait(1000, function() return settled end), 'picker cleanup did not finish')
end
vim.cmd('Neotree close')
vim.o.columns, vim.o.lines = old_columns, old_lines
assert(require('mason.settings').current.ui.backdrop == 100, 'Mason must not add a dim backdrop')
assert(require('lazy.core.config').options.ui.backdrop == 100, 'Lazy must not add a dim backdrop')
-- Selection and diff are intentional semantic colors, not canvas leftovers.
for _, name in ipairs { 'Visual', 'Search', 'DiffAdd', 'DiffDelete', 'PmenuSel' } do
  assert(vim.api.nvim_get_hl(0, { name = name, link = false }).bg, 'semantic color removed: ' .. name)
end
print('PASS: real Neo-tree/compact and wide picker windows remain transparent across theme reload')
