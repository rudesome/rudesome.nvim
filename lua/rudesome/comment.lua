-- NERDCommenter-style keymaps on top of Neovim's built-in commenting (gc / gcc).

-- Split 'commentstring' (e.g. "-- %s" or "/* %s */") into left/right parts.
local function comment_parts()
  local cs = vim.bo.commentstring
  if cs == nil or cs == "" then
    cs = "# %s"
  end
  local left, right = cs:match("^(.*)%%s(.*)$")
  return left or cs, right or ""
end

local function init()
  local map = vim.keymap.set

  -- Comment / toggle (built-in gcc toggles, which covers comment + uncomment)
  map("n", "<leader>cc", "gcc", { remap = true, desc = "Comment line" })
  map("x", "<leader>cc", "gc", { remap = true, desc = "Comment selection" })

  map("n", "<leader>c<Space>", "gcc", { remap = true, desc = "Toggle comment" })
  map("x", "<leader>c<Space>", "gc", { remap = true, desc = "Toggle comment (selection)" })

  map("n", "<leader>cu", "gcc", { remap = true, desc = "Uncomment line" })
  map("x", "<leader>cu", "gc", { remap = true, desc = "Uncomment selection" })

  map("n", "<leader>ci", "gcc", { remap = true, desc = "Invert comment" })
  map("x", "<leader>ci", "gc", { remap = true, desc = "Invert comment (selection)" })

  map("n", "<leader>cn", "gcc", { remap = true, desc = "Comment line (nested n/a, toggles)" })
  map("x", "<leader>cn", "gc", { remap = true, desc = "Comment selection (nested n/a, toggles)" })

  -- Yank first, then comment
  map("n", "<leader>cy", "yygcc", { remap = true, desc = "Yank line, then comment" })
  map("x", "<leader>cy", "ygvgc", { remap = true, desc = "Yank selection, then comment" })

  -- Comment from cursor to end of line
  map("n", "<leader>c$", function()
    local left, right = comment_parts()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local before = line:sub(1, col)
    local after = line:sub(col + 1)
    vim.api.nvim_set_current_line(before .. left .. after .. right)
  end, { desc = "Comment from cursor to EOL" })

  -- Append a comment at the end of the line and enter insert mode
  map("n", "<leader>cA", function()
    local left, right = comment_parts()
    local keys = "A " .. left
    if right ~= "" then
      keys = keys .. right .. string.rep("<Left>", vim.fn.strchars(right))
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
  end, { desc = "Append comment at EOL" })
end

return { init = init }
