vim.pack.add({
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/rcarriga/nvim-notify",
  "https://github.com/folke/noice.nvim",
})

require("notify").setup({ background_colour = "#000000" })
require("noice").setup({ presets = { lsp_doc_border = true } })
