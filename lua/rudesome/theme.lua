-- ============================================================
-- Theme – Gruvbox
-- ============================================================

local function init()
  -- Hard dark contrast for gruvbox (must be set before colorscheme)
  vim.g.gruvbox_contrast_dark   = "hard"
  vim.g.gruvbox_italic          = 1
  vim.g.gruvbox_invert_selection = 0

  vim.cmd.colorscheme("gruvbox")

  -- Override a few highlights after the colorscheme loads so they
  -- survive re-sourcing without an extra plugin.
  local hl = vim.api.nvim_set_hl

  -- Make the color column subtle rather than the harsh default
  hl(0, "ColorColumn",   { bg = "#3c3836" })

  -- Make the cursor line a touch warmer
  hl(0, "CursorLine",    { bg = "#32302f" })
  hl(0, "CursorLineNr",  { fg = "#fabd2f", bold = true })
end

return { init = init }
