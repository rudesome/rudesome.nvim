local function setup_gitsigns()
  require("gitsigns").setup({
    signs               = {
      add          = { text = "▎" },
      change       = { text = "▎" },
      delete       = { text = "" },
      topdelete    = { text = "" },
      changedelete = { text = "▎" },
      untracked    = { text = "▎" },
    },
    signcolumn          = true,
    numhl               = false,
    linehl              = false,
    word_diff           = false,
    watch_gitdir        = { follow_files = true },
    attach_to_untracked = true,
    current_line_blame  = false, -- toggle with <leader>gb

    on_attach           = function(bufnr)
      local gs  = package.loaded.gitsigns
      local map = vim.keymap.set
      local buf = { buffer = bufnr }

      -- Navigation
      map("n", "]h", function()
        if vim.wo.diff then return "]h" end
        vim.schedule(gs.next_hunk)
        return "<Ignore>"
      end, vim.tbl_extend("force", buf, { expr = true, desc = "Next hunk" }))

      map("n", "[h", function()
        if vim.wo.diff then return "[h" end
        vim.schedule(gs.prev_hunk)
        return "<Ignore>"
      end, vim.tbl_extend("force", buf, { expr = true, desc = "Prev hunk" }))

      -- Actions
      map("n", "<leader>hs", gs.stage_hunk, vim.tbl_extend("force", buf, { desc = "Stage hunk" }))
      map("n", "<leader>hr", gs.reset_hunk, vim.tbl_extend("force", buf, { desc = "Reset hunk" }))
      map("v", "<leader>hs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, vim.tbl_extend("force", buf, { desc = "Stage hunk (range)" }))
      map("v", "<leader>hr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, vim.tbl_extend("force", buf, { desc = "Reset hunk (range)" }))
      map("n", "<leader>hS", gs.stage_buffer, vim.tbl_extend("force", buf, { desc = "Stage buffer" }))
      map("n", "<leader>hu", gs.undo_stage_hunk, vim.tbl_extend("force", buf, { desc = "Undo stage hunk" }))
      map("n", "<leader>hR", gs.reset_buffer, vim.tbl_extend("force", buf, { desc = "Reset buffer" }))
      map("n", "<leader>hp", gs.preview_hunk, vim.tbl_extend("force", buf, { desc = "Preview hunk" }))
      map("n", "<leader>hb", function() gs.blame_line({ full = true }) end,
        vim.tbl_extend("force", buf, { desc = "Blame line" }))
      map("n", "<leader>gb", gs.toggle_current_line_blame, vim.tbl_extend("force", buf, { desc = "Toggle blame" }))
      map("n", "<leader>hd", gs.diffthis, vim.tbl_extend("force", buf, { desc = "Diff this" }))
      map("n", "<leader>hD", function() gs.diffthis("~") end, vim.tbl_extend("force", buf, { desc = "Diff this ~" }))

      -- Text objects
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", vim.tbl_extend("force", buf, { desc = "Select hunk" }))
    end,
  })
end

local function setup_harpoon()
  local harpoon = require("harpoon")
  harpoon:setup({})

  local map = vim.keymap.set

  map("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon: add file" })
  map("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: menu" })

  map("n", "<C-h>", function() harpoon:list():select(1) end, { desc = "Harpoon: file 1" })
  map("n", "<C-t>", function() harpoon:list():select(2) end, { desc = "Harpoon: file 2" })
  map("n", "<C-n>", function() harpoon:list():select(3) end, { desc = "Harpoon: file 3" })
  map("n", "<C-s>", function() harpoon:list():select(4) end, { desc = "Harpoon: file 4" })

  map("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "Harpoon: prev" })
  map("n", "<leader>hn", function() harpoon:list():next() end, { desc = "Harpoon: next" })
end

local function setup_colorizer()
  require("colorizer").setup({
    filetypes = { "*" },
    user_default_options = {
      RGB      = true,  -- #RGB
      RRGGBB   = true,  -- #RRGGBB
      names    = false, -- skip CSS colour names (noisy)
      RRGGBBAA = true,  -- #RRGGBBAA
      rgb_fn   = true,  -- CSS rgb() and rgba()
      hsl_fn   = true,  -- CSS hsl() and hsla()
      css      = true,  -- enable all CSS features
      mode     = "background",
    },
  })
end

local function setup_lualine()
  require("lualine").setup({
    options = {
      theme                = "gruvbox_dark",
      globalstatus         = true, -- single statusline across all windows
      component_separators = { left = "", right = "" },
      section_separators   = { left = "", right = "" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = {
        {
          "filename",
          file_status     = true,
          newfile_status  = true,
          path            = 1, -- relative path
          shorting_target = 40,
        },
      },
      lualine_x = { "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    inactive_sections = {
      lualine_c = { "filename" },
      lualine_x = { "location" },
    },
    extensions = { "quickfix", "man", "fzf" },
  })
end

local function setup_compile_mode()
  vim.g.compile_mode = {
    default_command = "",
  }
end

local function init()
  setup_gitsigns()
  setup_harpoon()
  setup_colorizer()
  setup_lualine()
  setup_compile_mode()
end

return { init = init }
