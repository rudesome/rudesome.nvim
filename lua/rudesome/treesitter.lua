local function init()
  require("nvim-treesitter.configs").setup({
    auto_install    = false,
    sync_install    = false,
    ensure_installed = {},
    ignore_install  = {},
    modules         = {},

    highlight = {
      enable = true,
      -- Disable for very large files to avoid performance issues
      disable = function(_, buf)
        local max_filesize = 500 * 1024 -- 500 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        return ok and stats and stats.size > max_filesize
      end,
      -- Use treesitter over vim regex-based highlighting for these filetypes
      additional_vim_regex_highlighting = false,
    },

    indent = { enable = true },

    -- Incremental selection using treesitter nodes
    incremental_selection = {
      enable  = true,
      keymaps = {
        init_selection    = "<C-space>",
        node_incremental  = "<C-space>",
        scope_incremental = "<C-s>",
        node_decremental  = "<bs>",
      },
    },
  })

  require("treesitter-context").setup({
    enable          = true,
    max_lines       = 4,   -- never show more than 4 lines of context
    min_window_height = 20, -- only show when window is tall enough
    line_numbers    = true,
    multiline_threshold = 1,
    trim_scope      = "outer",
    mode            = "cursor",
    separator       = nil,
    zindex          = 20,
  })
end

return { init = init }
