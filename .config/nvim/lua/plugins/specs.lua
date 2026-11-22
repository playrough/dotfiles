-- All plugin specs in one place, ordered by the load order in plugins/init.lua.
-- Add a plugin here before requiring its config module.

return {
  -- LSP / mason
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",

  -- formatting
  "https://github.com/stevearc/conform.nvim",

  -- completion
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("*") },
  { src = "https://github.com/rafamadriz/friendly-snippets" },

  -- treesitter
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
  },

  -- theme integration
  "https://github.com/daedlock/matugen.nvim",

  -- cmdline
  "https://github.com/rachartier/tiny-cmdline.nvim",

  -- telescope
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
  "https://github.com/nvim-telescope/telescope-ui-select.nvim",
  "https://github.com/nvim-telescope/telescope-frecency.nvim",

  -- git
  "https://github.com/lewis6991/gitsigns.nvim",

  -- statusline
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lualine/lualine.nvim",

  -- mini
  "https://github.com/echasnovski/mini.nvim",
  "https://github.com/nvim-mini/mini.files",
}
