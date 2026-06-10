local function setup_keymaps()
  vim.api.nvim_create_autocmd("LspAttach", {
    group    = vim.api.nvim_create_augroup("rudesome.lsp", { clear = true }),
    callback = function(args)
      local buf = args.buf
      local map = vim.keymap.set

      map("n", "gd", vim.lsp.buf.definition,  { buffer = buf, desc = "LSP definition" })
      map("n", "gD", vim.lsp.buf.declaration, { buffer = buf, desc = "LSP declaration" })
      map("n", "<leader>f", function()
        vim.lsp.buf.format({ async = true })
      end, { buffer = buf, desc = "LSP format" })

      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client:supports_method("textDocument/documentHighlight") then
        local group = vim.api.nvim_create_augroup("rudesome.lsp.highlight." .. buf, { clear = true })

        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          group    = group,
          buffer   = buf,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
          group    = group,
          buffer   = buf,
          callback = vim.lsp.buf.clear_references,
        })
      end
    end,
  })
end

local function setup_diagnostics()
  local severity = vim.diagnostic.severity

  vim.diagnostic.config({
    virtual_text = {
      prefix   = "●",
      severity = { min = severity.HINT },
    },
    signs = {
      text = {
        [severity.ERROR] = " ",
        [severity.WARN]  = " ",
        [severity.HINT]  = " ",
        [severity.INFO]  = " ",
      },
      texthl = {
        [severity.ERROR] = "DiagnosticSignError",
        [severity.WARN]  = "DiagnosticSignWarn",
        [severity.HINT]  = "DiagnosticSignHint",
        [severity.INFO]  = "DiagnosticSignInfo",
      },
      numhl = {
        [severity.ERROR] = "DiagnosticSignError",
        [severity.WARN]  = "DiagnosticSignWarn",
        [severity.HINT]  = "DiagnosticSignHint",
        [severity.INFO]  = "DiagnosticSignInfo",
      },
    },
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

  -- Diagnostic navigation (vim.diagnostic.goto_prev/next are deprecated in 0.11)
  local map = vim.keymap.set
  map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
  map("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
  end, { desc = "Prev diagnostic" })
  map("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
  end, { desc = "Next diagnostic" })
  map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic loclist" })
end

local function setup_servers()
  local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp then
    vim.lsp.config("*", { capabilities = cmp_lsp.default_capabilities() })
  end

  local language_servers = {
    bashls     = {},
    cssls      = {},

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
  for server, config in pairs(language_servers) do
    if next(config) then
      vim.lsp.config(server, config)
    end
    vim.lsp.enable(server)
  end
end

local function init()
  setup_diagnostics()
  setup_keymaps()
  setup_servers()
end

return { init = init }
