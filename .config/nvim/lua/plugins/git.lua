-- gitsigns: hunk signs in the signcolumn; ]h/[h and <leader>h* in lua/plugins/keymaps.lua.

vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
})

require("gitsigns").setup({
  signs = {
    add = { text = "▐" },
    change = { text = "▐" },
    delete = { text = "▐" },
    topdelete = { text = "◦" },
    changedelete = { text = "●" },
    untracked = { text = "○" },
  },
  signcolumn = true,
  current_line_blame = false,
})
