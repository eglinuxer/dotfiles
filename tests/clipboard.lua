-- Runs under --clean; never touches the real clipboard.
package.path = vim.fn.getcwd() .. '/nvim/lua/?.lua;' .. package.path
vim.env.SSH_CONNECTION = nil
vim.env.SSH_TTY = nil
require('clipboard_setup').setup()
assert(vim.g.clipboard == nil, 'local provider must remain auto-detected')
local emitted = {}
package.loaded['vim.ui.clipboard.osc52'] = {
  copy = function(reg)
    return function(lines) emitted[#emitted+1] = {reg=reg, lines=vim.deepcopy(lines)} end
  end,
}
vim.env.SSH_CONNECTION = 'test'
require('clipboard_setup').setup()
local provider = vim.g.clipboard
provider.copy['+']({'中文', 'line 2'}, 'V')
provider.copy['*']({'primary'}, 'v')
assert(#emitted == 2 and emitted[1].reg == '+' and emitted[2].reg == '*')
assert(vim.deep_equal(provider.paste['+'](), {{'中文', 'line 2'}, 'V'}))
assert(vim.deep_equal(provider.paste['*'](), {{'primary'}, 'v'}))
print('PASS: local provider untouched; remote copies and per-register cached paste')
vim.cmd('qa!')
