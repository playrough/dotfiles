-- LSP: install servers via mason, configure them. Attach keymaps in lua/plugins/keymaps.lua.
-- Diagnostic UI lives in lua/config/diagnostics.lua.

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
  ensure_installed = {
    -- LSP servers
    "lua_ls",
    "bashls",
    "jsonls",
    "cssls",
    "html",
    "pyright",
    "clangd",
    "ruff",

    -- Formatters (conform)
    "stylua",
    "shfmt",
    "clang-format",
    "oxfmt",
    "prettier",
    "prettierd",

    -- Linter (used directly by bashls, no nvim-lint needed)
    "shellcheck",

    -- Treesitter bootstrap (needed to build parsers)
    "tree-sitter-cli",
  },
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = {
          "vim",
          "require",
        },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
    "--query-driver=/usr/bin/gcc,/usr/bin/g++",
  },
})
