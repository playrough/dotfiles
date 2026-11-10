vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("*") },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
})

require("blink.cmp").setup({
  signature = {
    enabled = true,
  },

  keymap = {
    preset = "default",
    ["<Tab>"] = { "accept", "fallback" },
    ["<C-Space>"] = { "show" },
    ["<C-j>"] = { "select_next", "fallback" },
    ["<C-k>"] = { "select_prev", "fallback" },
  },

  fuzzy = {
    implementation = "rust",
  },
  completion = {
    ghost_text = {
      enabled = true,
    },
    menu = {
      auto_show = false,
    },
    documentation = {
      auto_show = true,
    },
  },
  cmdline = {
    keymap = { preset = "inherit" },
    completion = { menu = { auto_show = true } },
  },
})
