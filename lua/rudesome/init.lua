local function init()
  require 'rudesome.theme'.init()
  require 'rudesome.vim'.init()
  require 'rudesome.telescope'.init()
  require 'rudesome.floaterm'.init()
  require 'rudesome.languages'.init()
  require 'rudesome.treesitter'.init()
  require 'rudesome.extras'.init()
  require 'rudesome.completion'.init()
end

return {
  init = init,
}
