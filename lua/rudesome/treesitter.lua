local MAX_FILESIZE = 500 * 1024 -- 500 KB

local function file_too_large(buf)
  ---@diagnostic disable-next-line: undefined-field
  local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
  return ok and stats and stats.size and stats.size > MAX_FILESIZE
end

local function init()
  local augroup = vim.api.nvim_create_augroup("rudesome.treesitter", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
     group    = augroup,
     callback = function(args)
      local buf = args.buf
      local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
      if not lang then
        return
      end

      -- Skip very large files to keep the UI responsive.
      if file_too_large(buf) then
        return
      end

      pcall(vim.treesitter.start, buf, lang)
    end,
  })

  -- Indentation: replaces the legacy `indent = { enable = true }` block.
  vim.api.nvim_create_autocmd("FileType", {
     group    = augroup,
     callback = function(args)
      local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
      if not lang then
        return
      end
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })

  require("treesitter-context").setup({
    enable              = true,
    max_lines           = 4,   -- never show more than 4 lines of context
    min_window_height   = 20,  -- only show when window is tall enough
    line_numbers        = true,
    multiline_threshold = 1,
    trim_scope          = "outer",
    mode                = "cursor",
    separator           = nil,
    zindex              = 20,
  })
end

return { init = init }
