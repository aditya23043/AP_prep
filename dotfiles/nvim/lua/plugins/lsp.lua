local M = {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "folke/neodev.nvim",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Autoformatting
      "stevearc/conform.nvim",
    },
    config = function()
      require("neodev").setup({
        -- library = {
        --   plugins = { "nvim-dap-ui" },
        --   types = true,
        -- },
      })

      local capabilities = nil
      if pcall(require, "cmp_nvim_lsp") then
        capabilities = require("cmp_nvim_lsp").default_capabilities()
      end

      local lspconfig = require("lspconfig")

      local servers = {
        rust_analyzer = {},
        bashls = {},
        -- asm_ls = {},
        denols = {},
        -- pyright = {},
        lua_ls = {
          checkThirdParty = false,
          telemetry = { enable = false },
          library = {
            "/home/adi/.local/share/nvim/mason/packages/lua-language-server/libexec/meta/3rd/love2d/library",
            -- "${3rd}/love2d/library",
          },
          filetypes = { "lua" },
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
        },
        clangd = {
          init_options = { clangdFileStatus = true },
          filetypes = { "c", "cpp", },
        },

        -- htmx = {},

        -- ltex = {},
        jdtls = {},
        ast_grep = {
          default_config = {
            single_file_support = true,
          }
        },
        gopls = {},
        biome = {
          default_config = {
            single_file_support = true,
          }
        },
        emmet_ls = {},
        html = {},
        cssls = {},
        pylsp = {},
        pyright = {},
        verible = {},
      }

      local default_diagnostic_config = {
        signs = {
          text = {
            -- [vim.diagnostic.severity.ERROR] = '',
            -- [vim.diagnostic.severity.WARN] = '',
            -- [vim.diagnostic.severity.INFO] = '',
            -- [vim.diagnostic.severity.HINT] = ''
            -- [vim.diagnostic.severity.ERROR] = '',
            -- [vim.diagnostic.severity.WARN] = '',
            -- [vim.diagnostic.severity.INFO] = '',
            -- [vim.diagnostic.severity.HINT] = ''
            [vim.diagnostic.severity.ERROR] = '>>',
            [vim.diagnostic.severity.WARN] = '>>',
            [vim.diagnostic.severity.INFO] = '>>',
            [vim.diagnostic.severity.HINT] = '>>'
          }
        },

        virtual_text = true,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        open_float = {
          enable = true,
        },
        float = {
          enable = true,
          focusable = true,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      }
      vim.diagnostic.config(default_diagnostic_config)

      for _, sign in ipairs(vim.tbl_get(vim.diagnostic.config(), "signs", "values") or {}) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
      end

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
      vim.lsp.handlers["textDocument/signatureHelp"] =
          vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
      require("lspconfig.ui.windows").default_options.border = "rounded"

      local servers_to_install = vim.tbl_filter(function(key)
        local t = servers[key]
        if type(t) == "table" then
          return not t.manual_install
        else
          return t
        end
      end, vim.tbl_keys(servers))

      require("mason").setup()
      local ensure_installed = vim.tbl_keys(servers or {})

      vim.list_extend(ensure_installed, servers_to_install)
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      for name, config in pairs(servers) do
        if config == true then
          config = {}
        end
        config = vim.tbl_deep_extend("force", {}, {
          capabilities = capabilities,
        }, config)

        lspconfig[name].setup(config)
      end

      local disable_semantic_tokens = {
        lua = true,
      }

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

          vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = 0 })
          vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = 0 })
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = 0 })
          vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, { buffer = 0 })
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = 0 })
          vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { buffer = 0 })
          vim.keymap.set("n", "gl", vim.diagnostic.open_float, { buffer = 0 })

          vim.keymap.set("n", "<space>cr", vim.lsp.buf.rename, { buffer = 0 })
          vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, { buffer = 0 })

          local filetype = vim.bo[bufnr].filetype
          if disable_semantic_tokens[filetype] then
            client.server_capabilities.semanticTokensProvider = nil
          end
        end,
      })

      -- Autoformatting Setup
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "black" },
          cpp = { "clang-format" },
          java = { "clang-format" },
          javascript = { "biome" },
          c = { "clang-format" },
          markdown = { "prettier" },
          haskell = { "fourmolu" },
          rust = { "rustfmt" },
          go = { "crlfmt" },
          verilog = { "verible" },
          html = { "htmlbeautifier" },
          css = { "prettier" },
          -- asm = { "asmfmt" },
        },
      })

    end,
  },
}

return M
