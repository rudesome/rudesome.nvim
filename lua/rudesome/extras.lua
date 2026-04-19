local function setup_extras()
  require("gitsigns").setup()

  vim.g.compile_mode = {
    default_command = ''
  }

  --require("lsp-colors").setup()


  -- harpoon
  -- todo: move to seperator file
  --require("harpoon").setup()
  --local mark = require("harpoon.mark")
  --local ui = require("harpoon.ui")

  --vim.keymap.set("n", "<leader>a", mark.add_file)
  --vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

  --vim.keymap.set("n", "<C-h>", function() ui.nav_file(1) end)
  --vim.keymap.set("n", "<C-t>", function() ui.nav_file(2) end)
  --vim.keymap.set("n", "<C-n>", function() ui.nav_file(3) end)
  --vim.keymap.set("n", "<C-s>", function() ui.nav_file(4) end)

  --require("lsp_lines").setup()

  require("lualine").setup({
    options = {
      extensions = { 'fzf', 'quickfix' },
      theme = 'gruvbox_dark',
    },
    sections = {
      lualine_a = {
        {
          'filename',
          file_status = true,  -- displays file status (readonly status, modified status)
          path = 0,            -- 0 = just filename, 1 = relative path, 2 = absolute path
          shorting_target = 40 -- Shortens path to leave 40 space in the window
        }
      }
    }
  })

  --vim.diagnostic.config({
  --virtual_text = true;
  --virtual_lines = {
  --only_current_line = true,
  --}
  --})
end

local function init()
  setup_extras()
end

return {
  init = init,
}
