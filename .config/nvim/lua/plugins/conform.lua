-- conform.nvim: one CLI formatter per filetype group.
-- oxfmt covers js/ts/json/yaml/toml/markdown/css/html; prettierd/prettier are only a
-- fallback layer (stop_after_first = first formatter that is *installed*).

local format_chain = { "oxfmt", "prettierd", "prettier", stop_after_first = true }

require("conform").setup({
  default_format_opts = {
    timeout_ms = 3000,
    lsp_format = "fallback",
  },
  formatters_by_ft = {
    lua = { "stylua" },

    sh = { "shfmt" },
    bash = { "shfmt" },

    c = { "clang_format" },
    cpp = { "clang_format" },

    python = { "ruff_organize_imports", "ruff_format" },

    toml = format_chain,
    json = format_chain,
    jsonc = format_chain,
    yaml = format_chain,
    markdown = format_chain,
    html = format_chain,
    css = format_chain,
    scss = format_chain,
    less = format_chain,
    javascript = format_chain,
    javascriptreact = format_chain,
    typescript = format_chain,
    typescriptreact = format_chain,
  },
  format_on_save = function(bufnr)
    if vim.b[bufnr].disable_autoformat then
      return
    end
    return {
      timeout_ms = 500,
      lsp_format = "fallback",
    }
  end,
})
