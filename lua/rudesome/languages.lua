--local lspconfig = require 'lspconfig'
local treesitter = require 'nvim-treesitter.configs'
local treesitter_context = require 'treesitter-context'

local function autocmd(args)
  local event = args[1]
  local group = args[2]
  local callback = args[3]

  vim.api.nvim_create_autocmd(event, {
    group = group,
    buffer = args[4],
    callback = function()
      callback()
    end,
    once = args.once,
  })
end

local function on_attach(client, bufnr)
  local augroup_highlight = vim.api.nvim_create_augroup("custom-lsp-references", { clear = true })
  local autocmd_clear = vim.api.nvim_clear_autocmds

  local bufopts = { buffer = bufnr, remap = false }

  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)

  if client.server_capabilities.documentHighlightProvider then
    autocmd_clear { group = augroup_highlight, buffer = bufnr }
    autocmd { "CursorHold", augroup_highlight, vim.lsp.buf.document_highlight, bufnr }
    autocmd { "CursorMoved", augroup_highlight, vim.lsp.buf.clear_references, bufnr }
  end
end

local function setup_languages()
  ---- Diagnostics
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      --defines error in line via keybinding
      virtual_text = true,
      --underline = { severity_limit = "Error" },
      signs = true,
      update_in_insert = false,
    }
  )

  local language_servers = {
    bashls = {},
    cssls = {},
    clangd = {},
    diagnosticls = {
      filetypes = { "python" },
      init_options = {
        filetypes = {
          python = "black"
        },
        formatFiletypes = {
          python = { "black" }
        },
        formatters = {
          black = {
            command = "black",
            args = { "--quiet", "-" },
            rootPatterns = { "pyproject.toml" },
          },
        },
      }
    },
    dhall_lsp_server = {},
    dockerls = {},
    gopls = {
      settings = {
        gopls = {
          gofumpt = true,
        },
      },
    },
    html = {},
    jsonls = {},
    jsonnet_ls = {},
    lua_ls = {
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' }
          },
          runtime = {
            version = 'LuaJIT',
          },
          telemetry = {
            enable = false,
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
          },
        },
      }
    },
    marksman = {},
    nickel_ls = {},
    nil_ls = {
      settings = {
        ['nil'] = {
          formatting = { command = { "alejandra" } },
          nix = {
            flake = {
              autoArchive = true,
              autoUpdateLockFile = false,
            },
          },
        },
      }
    },
    ocamllsp = {},
    --omnisharp = {
    --cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
    --handlers = {
    --["textDocument/definition"] = omnisharp_extended.handler,
    --},
    --},
    postgres_lsp = {},
    powershell_es = {
      config = {
        bundle_path = "/home/rudesome/PowerShellEditorServices"
      }
    },
    pyright = {
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            diagnosticMode = "workspace",
            useLibraryCodeForTypes = true
          },
        },
      },
    },
    terraformls = {},
    --ts_ls = {},
    yamlls = {
      settings = {
        yaml = {
          keyOrdering = false,
        },
      },
    },
    zls = {},
  }

  -- Initialize servers
  for server, server_config in pairs(language_servers) do
    local config = { on_attach = on_attach }

    if server_config then
      for k, v in pairs(server_config) do
        config[k] = v
      end
    end

    vim.lsp.enable(server)
    vim.lsp.config(server, config)
  end

  -- Global mappings.
  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

  treesitter.setup {
    auto_install = false,
    ensure_installed = {},
    highlight = { enable = true },
    ignore_install = {},
    indent = { enable = true },
    modules = {},
    rainbow = { enable = true },
    sync_install = false,
  }

  treesitter_context.setup()
end

local function init()
  setup_languages()
end

return {
  init = init,
}
