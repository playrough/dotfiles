vim.pack.add({
  "https://github.com/daedlock/matugen.nvim",
})

require("matugen").setup({
	colors_path = "~/.config/nvim/colors.json",
	watch = true,
	brightness = 0,
	contrast = -0.05,
	sidebar_brightness = 0,
	harmonize = 15,
	min_contrast = 0.45,
	overrides = {},
})

vim.cmd.colorscheme("matugen")
