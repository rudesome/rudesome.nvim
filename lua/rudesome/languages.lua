-- ============================================================
-- LSP configuration
-- ============================================================
-- Treesitter is configured separately in treesitter.lua.
-- This module only handles LSP servers and diagnostics.

-- ------------------------------------------------------------
-- Shared LSP on_attach
-- ------------------------------------------------------------
local function on_attach(client, bufnr)
  local map     = vim.keymap.set
  local buf     = { buffer = bufnr, silent = true }

  -- Navigation
  map("n", "gD",         vim.lsp.buf.declaration,    vim.tbl_extend("force", buf, { desc = "LSP declaration" }))
  map("n", "gd",         vim.lsp.buf.definition,     vim.tbl_extend("force", buf, { desc = "LSP definition" }))
  map("n", "gi",         vim.lsp.buf.implementation, vim.tbl_extend("force", buf, { desc = "LSP implementation" }))
  map("n", "gr",         vim.lsp.buf.references,     vim.tbl_extend("force", buf, { desc = "LSP references" }))
  map("n", "gy",         vim.lsp.buf.type_definition,vim.tbl_extend("force", buf, { desc = "LSP type definition" }))

  -- Hover / signature
  map("n", "K",          vim.lsp.buf.hover,          vim.tbl_extend("force", buf, { desc = "LSP hover" }))
  map("n", "<C-k>",      vim.lsp.buf.signature_help, vim.tbl_extend("force", buf, { desc = "LSP signature help" }))
  map("i", "<C-k>",      vim.lsp.buf.signature_help, vim.tbl_extend("force", buf, { desc = "LSP signature help" }))

  -- Code actions / rename / format
  map("n", "<leader>rn", vim.lsp.buf.rename,         vim.tbl_extend("force", buf, { desc = "LSP rename" }))
  map("n", "<leader>ca", vim.lsp.buf.code_action,    vim.tbl_extend("force", buf, { desc = "LSP code action" }))
  map("v", "<leader>ca", vim.lsp.buf.code_action,    vim.tbl_extend("force", buf, { desc = "LSP code action (range)" }))
  map("n", "<leader>f",  function()
    vim.lsp.buf.format({ async = true })
  end, vim.tbl_extend("force", buf, { desc = "LSP format" }))

  -- Workspace folders
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder,    vim.tbl_extend("force", buf, { desc = "Add workspace folder" }))
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, vim.tbl_extend("force", buf, { desc = "Remove workspace folder" }))
  map("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, vim.tbl_extend("force", buf, { desc = "List workspace folders" }))

  -- Document highlight (if server supports it)
  if client.server_capabilities.documentHighlightProvider then
    local augroup = vim.api.nvim_create_augroup("lsp_document_highlight_" .. bufnr, { clear = true })

    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group    = augroup,
      buffer   = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group    = augroup,
      buffer   = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

-- ------------------------------------------------------------
-- Diagnostics display
-- ------------------------------------------------------------
local function setup_diagnostics()
  local signs = {
    Error = " ",
    Warn  = " ",
    Hint  = " ",
    Info  = " ",
  }

  -- Define sign icons (Neovim ≥ 0.10 uses vim.diagnostic.config signs table)
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  vim.diagnostic.config({
    virtual_text = {
      prefix   = "●",
      severity = { min = vim.diagnostic.severity.HINT },
    },
    signs            = true,
    underline        = true,
    update_in_insert = false,
    severity_sort    = true,
    float = {
      focusable = false,
      style     = "minimal",
      border    = "rounded",
      source    = "always",
      header    = "",
      prefix    = "",
    },
  })

  -- Diagnostic navigation
  local map = vim.keymap.set
  map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
  map("n", "[d",        vim.diagnostic.goto_prev,  { desc = "Prev diagnostic" })
  map("n", "]d",        vim.diagnostic.goto_next,  { desc = "Next diagnostic" })
  map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic loclist" })
end

-- ------------------------------------------------------------
-- Language server definitions
-- ------------------------------------------------------------
local function setup_servers()
  -- Build capabilities table enhanced with nvim-cmp LSP completions
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp then
    capabilities = cmp_lsp.default_capabilities(capabilities)
  end

  local language_servers = {
    bashls     = {},
    cssls      = {},
    clangd     = {},

    -- Python: diagnosticls for formatting, pyright for type-checking
    diagnosticls = {
      filetypes = { "python" },
      init_options = {
        filetypes       = { python = "black" },
        formatFiletypes = { python = { "black" } },
        formatters = {
          black = {
            command      = "black",
            args         = { "--quiet", "-" },
            rootPatterns = { "pyproject.toml" },
          },
        },
      },
    },

    dhall_lsp_server = {},
    dockerls         = {},

    gopls = {
      settings = {
        gopls = {
          gofumpt    = true,
          staticcheck = true,
          analyses   = {
            unusedparams = true,
          },
        },
      },
    },

    html   = {},
    jsonls = {},
    jsonnet_ls = {},

    lua_ls = {
      settings = {
        Lua = {
          runtime     = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace   = {
            library          = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty  = false,
          },
          telemetry   = { enable = false },
          format      = { enable = false }, -- let stylua handle formatting
        },
      },
    },

    marksman  = {},
    nickel_ls = {},

    nil_ls = {
      settings = {
        ["nil"] = {
          formatting = { command = { "alejandra" } },
          nix = {
            flake = {
              autoArchive        = true,
              autoUpdateLockFile = false,
            },
          },
        },
      },
    },

    ocamllsp = {},

    postgres_lsp = {},

    powershell_es = {
      config = {
        bundle_path = "/home/rudesome/PowerShellEditorServices",
      },
    },

    pyright = {
      settings = {
        python = {
          analysis = {
            autoSearchPaths  = true,
            diagnosticMode   = "workspace",
            useLibraryCodeForTypes = true,
          },
        },
      },
    },

    terraformls = {},

    ts_ls = {},

    yamlls = {
      settings = {
        yaml = { keyOrdering = false },
      },
    },

    zls = {},
  }

  -- Register every server using the modern vim.lsp API
  for server, server_config in pairs(language_servers) do
    local config = vim.tbl_deep_extend("force", {
      on_attach    = on_attach,
      capabilities = capabilities,
    }, server_config)

    vim.lsp.config(server, config)
    vim.lsp.enable(server)
  end
end

-- ------------------------------------------------------------
-- Entry point
-- ------------------------------------------------------------
local function init()
  setup_diagnostics()
  setup_servers()
end

return { init = init }
