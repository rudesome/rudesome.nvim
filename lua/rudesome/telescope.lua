-- ============================================================
-- Telescope – fuzzy finder
-- ============================================================

local function init()
  local telescope = require("telescope")
  local builtin   = require("telescope.builtin")
  local actions   = require("telescope.actions")

  telescope.setup({
    defaults = {
      -- Files to exclude from all pickers
      file_ignore_patterns = {
        "node_modules/.*",
        "secret%.d/.*",
        "%.pem$",
        "%.lock$",
        "^%.git/",
      },

      -- Layout
      layout_strategy = "horizontal",
      layout_config   = {
        horizontal = { preview_width = 0.55, width = 0.87, height = 0.80 },
        vertical   = { mirror = false },
      },
      sorting_strategy = "ascending",
      prompt_prefix    = "  ",
      selection_caret  = " ",
      path_display     = { "truncate" },

      -- Key overrides inside the picker
      mappings = {
        i = {
          ["<C-j>"]   = actions.move_selection_next,
          ["<C-k>"]   = actions.move_selection_previous,
          ["<C-q>"]   = actions.send_selected_to_qflist + actions.open_qflist,
          ["<Esc>"]   = actions.close,
          ["<C-u>"]   = false, -- allow clearing the prompt with C-u
        },
      },
    },

    pickers = {
      find_files = { hidden = true },
      buffers    = {
        sort_mru     = true,
        ignore_current_buffer = true,
      },
    },
  })

  -- -------------------------------------------------------
  -- Keymaps
  -- -------------------------------------------------------
  local map = vim.keymap.set

  -- Files
  map("n", "<leader>fg", builtin.git_files,                           { desc = "Git files" })
  map("n", "<leader>ff", builtin.find_files,                          { desc = "Find files" })
  map("n", "<leader>fl", builtin.live_grep,                           { desc = "Live grep" })
  map("n", "<leader>fb", builtin.buffers,                             { desc = "Buffers" })
  map("n", "<leader>fh", builtin.help_tags,                           { desc = "Help tags" })
  map("n", "<leader>fr", builtin.registers,                           { desc = "Registers" })
  map("n", "<leader>fo", builtin.oldfiles,                            { desc = "Recent files" })
  map("n", "<leader>fk", builtin.keymaps,                             { desc = "Keymaps" })
  map("n", "<leader>fs", builtin.grep_string,                         { desc = "Grep word under cursor" })
  map("n", "<leader>f/", function()
    builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
      winblend = 10,
      previewer = false,
    }))
  end, { desc = "Fuzzy find in buffer" })

  -- Diagnostics
  map("n", "<leader>fd", builtin.diagnostics,                         { desc = "Workspace diagnostics" })

  -- LSP pickers (modern names – lsp_code_actions was removed; use vim.lsp.buf.code_action)
  map("n", "<leader>lsd", builtin.lsp_definitions,                    { desc = "LSP definitions" })
  map("n", "<leader>lsi", builtin.lsp_implementations,                { desc = "LSP implementations" })
  map("n", "<leader>lst", builtin.lsp_type_definitions,               { desc = "LSP type definitions" })
  map("n", "<leader>lsr", builtin.lsp_references,                     { desc = "LSP references" })
  map("n", "<leader>lss", builtin.lsp_document_symbols,               { desc = "LSP document symbols" })
  map("n", "<leader>lsw", builtin.lsp_workspace_symbols,              { desc = "LSP workspace symbols" })
end

return { init = init }
