-- matugen: generate color palette from wallpaper into colors.json; theme reads it back.

vim.pack.add({
  "https://github.com/daedlock/matugen.nvim",
})

require("matugen").setup({
  colors_path = vim.fn.stdpath("config") .. "/colors.json",
  watch = true,
  brightness = 0,
  contrast = -0.05,
  sidebar_brightness = 0,
  harmonize = 15,
  min_contrast = 0.45,
})

vim.cmd.colorscheme("matugen")
