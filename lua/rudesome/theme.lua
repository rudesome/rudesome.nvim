local function setup_theme()
  vim.g.gruvbox_contrast_dark='hard'
  vim.cmd("colorscheme gruvbox")
end


local function init()
  setup_theme()
end

return {
  init = init
}
