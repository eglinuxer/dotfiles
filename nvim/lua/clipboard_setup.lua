local M = {}
function M.setup()
  if not (vim.env.SSH_CONNECTION or vim.env.SSH_TTY) then return end
  -- Copy over OSC 52; paste returns our last copy without a blocking read request.
  local saved = { ["+"] = { {}, "v" }, ["*"] = { {}, "v" } }
  local copy, paste = {}, {}
  for _, reg in ipairs { "+", "*" } do
    local send = require("vim.ui.clipboard.osc52").copy(reg)
    copy[reg] = function(lines, regtype)
      saved[reg] = { vim.deepcopy(lines), regtype }
      send(lines)
    end
    paste[reg] = function() return saved[reg] end
  end
  vim.g.clipboard = { name = "SSH OSC 52 (copy; cached paste)", copy = copy, paste = paste, cache_enabled = 0 }
end
return M
