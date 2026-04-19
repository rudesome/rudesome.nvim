local modules = {
  "rudesome.theme",
  "rudesome.vim",
  "rudesome.treesitter",
  "rudesome.telescope",
  "rudesome.languages",
  "rudesome.completion",
  "rudesome.floaterm",
  "rudesome.extras",
}

local function init()
  for _, mod in ipairs(modules) do
    local ok, err = pcall(function()
      require(mod).init()
    end)

    if not ok then
      vim.notify(
        string.format("[rudesome] failed to load '%s':\n%s", mod, err),
        vim.log.levels.ERROR,
        { title = "rudesome.nvim" }
      )
    end
  end
end

return { init = init }
