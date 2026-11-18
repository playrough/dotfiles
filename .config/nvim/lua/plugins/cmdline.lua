-- tiny-cmdline: floating cmdline in the middle of the screen. Highlights in lua/config/theme.lua.

vim.pack.add({ "https://github.com/rachartier/tiny-cmdline.nvim" })

require("tiny-cmdline").setup({
  position = {
    x = "50%",
    y = "50%",
  },
})
