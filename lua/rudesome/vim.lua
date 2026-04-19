local opt        = vim.opt
local g          = vim.g
local api        = vim.api

g.mapleader      = " "
g.maplocalleader = " "

local function set_options()
  -- UI
  opt.number         = true
  opt.relativenumber = true
  opt.signcolumn     = "yes" -- always show; avoids layout shift
  opt.colorcolumn    = "80"
  opt.cursorline     = true
  opt.termguicolors  = true
  opt.showmode       = false -- lualine already shows the mode
  opt.wrap           = false
  opt.scrolloff      = 12
  opt.sidescrolloff  = 8

  -- Indentation
  opt.expandtab      = true
  opt.tabstop        = 2
  opt.softtabstop    = 2
  opt.shiftwidth     = 2
  opt.smartindent    = true

  -- Search
  opt.hlsearch       = false
  opt.incsearch      = true
  opt.ignorecase     = true
  opt.smartcase      = true

  -- Files / buffers
  opt.hidden         = true
  opt.swapfile       = false
  opt.backup         = false
  opt.writebackup    = false
  opt.undofile       = true -- persistent undo
  opt.updatetime     = 250
  opt.timeoutlen     = 400

  -- Splits
  opt.splitright     = true
  opt.splitbelow     = true

  -- Clipboard
  opt.clipboard      = "unnamedplus"

  -- Completion
  opt.completeopt    = { "menu", "menuone", "noselect" }
  opt.shortmess:append("c")

  -- Encoding & misc
  opt.encoding     = "utf-8"
  opt.fileencoding = "utf-8"
  opt.secure       = true

  -- Whitespace indicators
  opt.list         = true
  opt.listchars    = {
    eol      = "↲",
    tab      = "» ",
    trail    = "·",
    extends  = "›",
    precedes = "‹",
    nbsp     = "␣",
  }
end

local function set_autocmds()
  -- Highlight yanked text briefly
  api.nvim_create_autocmd("TextYankPost", {
    group    = api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
      vim.highlight.on_yank({ timeout = 240 })
    end,
  })

  -- Wrap long lines only in Markdown / text files
  api.nvim_create_autocmd("FileType", {
    group    = api.nvim_create_augroup("wrap_in_prose", { clear = true }),
    pattern  = { "markdown", "text", "gitcommit" },
    callback = function()
      opt.wrap        = true
      opt.linebreak   = true
      opt.breakindent = true
    end,
  })

  -- Remove trailing whitespace on save
  api.nvim_create_autocmd("BufWritePre", {
    group    = api.nvim_create_augroup("trim_whitespace", { clear = true }),
    pattern  = "*",
    callback = function()
      local pos = api.nvim_win_get_cursor(0)
      vim.cmd([[%s/\s\+$//e]])
      api.nvim_win_set_cursor(0, pos)
    end,
  })

  -- Equalize splits when Neovim is resized
  api.nvim_create_autocmd("VimResized", {
    group    = api.nvim_create_augroup("equalize_splits", { clear = true }),
    callback = function()
      vim.cmd("tabdo wincmd =")
    end,
  })
end

local function set_keymaps()
  local map = vim.keymap.set

  -- Window navigation
  map("n", "<leader>h", "<CMD>wincmd h<CR>", { desc = "Move to left window" })
  map("n", "<leader>j", "<CMD>wincmd j<CR>", { desc = "Move to lower window" })
  map("n", "<leader>k", "<CMD>wincmd k<CR>", { desc = "Move to upper window" })
  map("n", "<leader>l", "<CMD>wincmd l<CR>", { desc = "Move to right window" })

  -- Centered search navigation
  map("n", "n", "nzzzv", { desc = "Next result (centered)" })
  map("n", "N", "Nzzzv", { desc = "Prev result (centered)" })

  -- Centered half-page scrolling
  map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down (centered)" })
  map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up (centered)" })

  -- Move selected lines up/down in visual mode
  map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
  map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

  -- Yank helpers (ThePrimeagen-style)
  map("n", "Y", "y$", { desc = "Yank to end of line" })
  map("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
  map("v", "<leader>y", '"+y', { desc = "Yank selection to system clipboard" })
  map("n", "<leader>Y", 'gg"+yG', { desc = "Yank whole file to system clipboard" })

  -- Delete to black hole register (don't pollute yank register)
  map("n", "<leader>d", '"_d', { desc = "Delete to void" })
  map("v", "<leader>d", '"_d', { desc = "Delete selection to void" })

  -- Quick config reload
  map("n", "<leader>sv", "<CMD>source $MYVIMRC<CR>", { desc = "Source init.lua" })

  -- Buffer management
  map("n", "<leader>bd", "<CMD>bdelete<CR>", { desc = "Delete buffer" })
  map("n", "<leader>bn", "<CMD>bnext<CR>", { desc = "Next buffer" })
  map("n", "<leader>bp", "<CMD>bprevious<CR>", { desc = "Prev buffer" })

  -- Clear search highlight
  map("n", "<Esc>", "<CMD>nohlsearch<CR>", { desc = "Clear search highlight" })

  -- Stay in indent mode after tab in visual
  map("v", "<", "<gv", { desc = "Indent left and reselect" })
  map("v", ">", ">gv", { desc = "Indent right and reselect" })
end

local function init()
  set_options()
  set_autocmds()
  set_keymaps()
end

return { init = init }
