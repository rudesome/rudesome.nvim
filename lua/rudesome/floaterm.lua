local function init()
  local map             = vim.keymap.set

  -- Default floaterm dimensions
  vim.g.floaterm_width  = 0.9
  vim.g.floaterm_height = 0.9

  -- Allow <Esc> to switch to normal mode inside a floaterm
  vim.api.nvim_create_autocmd("FileType", {
    group    = vim.api.nvim_create_augroup("floaterm_keymaps", { clear = true }),
    pattern  = "floaterm",
    callback = function()
      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = true, desc = "Floaterm: normal mode" })
    end,
  })

  local float_cmd = function(prog, opts)
    opts = opts or {}
    local w = opts.width or 0.9
    local h = opts.height or 0.9
    return string.format(
      "<CMD>FloatermNew --autoclose=2 --height=%s --width=%s %s<CR>",
      h, w, prog
    )
  end

  map("n", "<leader>tt", float_cmd("zsh"), { desc = "Floaterm: shell" })
  map("n", "<leader>lg", float_cmd("lazygit"), { desc = "Floaterm: lazygit" })
  map("n", "<leader>ld", float_cmd("lazydocker"), { desc = "Floaterm: lazydocker" })
  map("n", "<leader>k9", float_cmd("k9s"), { desc = "Floaterm: k9s" })
  map("n", "<leader>bb", float_cmd("btm"), { desc = "Floaterm: btm (bottom)" })
  map("n", "<leader>tw", float_cmd("taskwarrior-tui"), { desc = "Floaterm: taskwarrior" })
  map("n", "<leader>nn", float_cmd("nnn -Hde", { width = 0.5, height = 0.5 }), { desc = "Floaterm: nnn" })

  -- Toggle / cycle existing floaterms
  map("n", "<leader>tf", "<CMD>FloatermToggle<CR>", { desc = "Floaterm: toggle" })
  map("t", "<leader>tf", "<CMD>FloatermToggle<CR>", { desc = "Floaterm: toggle" })
  map("n", "<leader>tn", "<CMD>FloatermNext<CR>", { desc = "Floaterm: next" })
  map("n", "<leader>tp", "<CMD>FloatermPrev<CR>", { desc = "Floaterm: prev" })
end

return { init = init }
