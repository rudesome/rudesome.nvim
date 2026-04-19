local treesitter = require 'nvim-treesitter.configs'
local treesitter_context = require 'treesitter-context'

local function init()
  treesitter.setup {
    --highlight = { enable = true },
    --indent = { enable = true },
    --rainbow = { enable = true },
    auto_install = false,
    ensure_installed = {},
    highlight = { enable = true },
    ignore_install = {},
    indent = { enable = true },
    modules = {},
    rainbow = { enable = true },
    sync_install = false,
  }
  treesitter_context.setup()
end

return {
  init = init,
}
