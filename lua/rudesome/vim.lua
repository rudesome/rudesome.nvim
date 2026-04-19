local function set_augroup()
  vim.api.nvim_command("augroup WrapInMarkdown")
  vim.api.nvim_command("autocmd!")
  vim.api.nvim_command("autocmd FileType markdown setlocal wrap")
  vim.api.nvim_command("augroup END")
  vim.api.nvim_command("augroup highlight_yank")
  vim.api.nvim_command("autocmd!")
  vim.api.nvim_command("autocmd TextYankPost * silent! lua vim.highlight.on_yank({timeout = 240})")
  vim.api.nvim_command("augroup END")
end

local function set_vim_g()
  vim.g.mapleader = " "
end

local function set_vim_o()
  local settings = {
    --backup = false,
    --errorbells = false,
    clipboard = 'unnamedplus',
    expandtab = true,
    hidden = true,
    scrolloff = 12,
    softtabstop = 2,
    showmode = false,
    tabstop = 2,
    termguicolors = true,
    updatetime = 300
    --number = true
  }

  -- Generic vim.o
  for k, v in pairs(settings) do
    vim.o[k] = v
  end

  vim.cmd("set colorcolumn=80")

  -- Custom vim.o
  vim.o.clipboard = 'unnamedplus'
  vim.o.shortmess = vim.o.shortmess .. 'c'

  -- Not yet in vim.o
  vim.cmd('set encoding=utf8')
  vim.cmd('set nowritebackup')
  vim.cmd('set shiftwidth=2')
  vim.cmd('set secure')
  vim.cmd('set splitright')
  --vim.cmd('set tabstop=2')
  --vim.cmd('set updatetime=300')
  vim.cmd('set nohlsearch')
end

local function set_vim_wo()
  vim.wo.number = true
  vim.wo.relativenumber = true
  vim.wo.wrap = false
end

local function set_vim_opt()
    vim.opt.list = true
    vim.opt.listchars:append "eol:↲"
end

local function set_keymaps()
  local map = vim.api.nvim_set_keymap

  local options = { noremap = false }

  map('n', '<leader>h', '<CMD>wincmd h<CR>', options)
  map('n', '<leader>j', '<CMD>wincmd j<CR>', options)
  map('n', '<leader>k', '<CMD>wincmd k<CR>', options)
  map('n', '<leader>l', '<CMD>wincmd l<CR>', options)

  -- keep search result centered
  map('n', 'n', 'nzzzv', options)
  map('n', 'N', 'Nzzzv', options)

  -- keep center while go half page up/down
  map('n', '<C-d>', '<C-d>zz', options)
  map('n', '<C-u>', '<C-u>zz', options)

	-- drag selected up or down and keep cursor at where it is at
  --map('v', 'J', ':m \'>+1<CR>gv=gv', options)
  --map('v', 'K', ':m \'<-2<CR>gv=gv', options)

  -- next greatest remap ever : asbjornHaland
  map('n', 'Y', 'y$', options)
  map('n', '<leader>y', '"+y', options)
  map('v', '<leader>y', '"+y', options)
  map('n', '<leader>Y', 'gg"+yG', options)

  map('n', '<leader>d', '"_d', options)
  map('v', '<leader>d', '"_d', options)
end

local function init()
  set_augroup()
  set_vim_g()
  set_vim_o()
  set_vim_wo()
  set_vim_opt()
  set_keymaps()
end

return {
  init = init
}
