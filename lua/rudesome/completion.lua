local function init()
  local cmp     = require("cmp")
  local luasnip = require("luasnip")
  local lspkind = require("lspkind")

  require("luasnip.loaders.from_vscode").lazy_load()

  local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0
      and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%S") ~= nil
  end

  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },

    window = {
      completion    = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },

    -- Mappings
    mapping = cmp.mapping.preset.insert({
      -- Tab / S-Tab: cycle through items or expand/jump snippets
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
        elseif luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
        elseif luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),

      -- Scroll docs
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),

      -- Explicitly open completion menu
      ["<C-Space>"] = cmp.mapping.complete(),

      -- Abort
      ["<C-e>"] = cmp.mapping.abort(),

      -- Confirm (select = false: only confirm explicitly selected item)
      ["<CR>"] = cmp.mapping.confirm({ select = false }),
    }),

    -- Sources (ordered by priority)
    sources = cmp.config.sources({
      { name = "nvim_lsp",               priority = 1000 },
      { name = "luasnip",                priority = 750  },
      { name = "nvim_lua",               priority = 500  },
      { name = "path",                   priority = 400  },
    }, {
      { name = "buffer",   keyword_length = 4, priority = 200 },
    }),

    -- Formatting
    formatting = {
      format = lspkind.cmp_format({
        mode     = "symbol_text",
        maxwidth = 50,
        ellipsis_char = "…",
        menu = {
          nvim_lsp = "[LSP]",
          luasnip  = "[Snip]",
          nvim_lua = "[Lua]",
          path     = "[Path]",
          buffer   = "[Buf]",
        },
      }),
    },

    -- Misc
    experimental = {
      ghost_text = { hl_group = "CmpGhostText" },
    },
  })

  cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = "buffer" } },
  })

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources(
      { { name = "path" } },
      { { name = "cmdline" } }
    ),
  })
end

return { init = init }
