local function get_matugen_colors()
	local path = vim.fn.expand("~/.config/nvim/colors.json")
	local file = io.open(path, "r")

	if not file then
		return {}
	end

	local content = file:read("*a")
	file:close()

	return vim.json.decode(content)
end

local colors = get_matugen_colors()

vim.pack.add({ "https://github.com/rachartier/tiny-cmdline.nvim" })

require("tiny-cmdline").setup({
	position = {
		x = "50%",
		y = "50%",
	},
})

-- TinyCmd
vim.api.nvim_set_hl(0, "TinyCmdlineBorder", {
	fg = colors.on_secondary,
})

vim.api.nvim_set_hl(0, "TinyCmdlineNormal", {
	fg = colors.on_surface,
	bg = colors.surface,
})

-- BlinkCmp
vim.api.nvim_set_hl(0, "BlinkCmpMenu", {
	fg = colors.on_surface,
	bg = colors.surface,
})

vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", {
	fg = colors.on_secondary,
})

vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", {
	fg = colors.primary,
	bg = colors.surface_container_low,
})

vim.api.nvim_set_hl(0, "BlinkCmpScrollBarThumb", {
	bg = colors.on_secondary,
})

vim.api.nvim_set_hl(0, "BlinkCmpGhostText", {
	fg = colors.outline_variant,
})

vim.api.nvim_set_hl(0, "BlinkCmpDoc", {
	fg = colors.on_surface,
	bg = colors.surface,
})

vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", {
	fg = colors.on_secondary,
})

vim.api.nvim_set_hl(0, "BlinkCmpDocSeparator", {
	fg = colors.on_secondary,
})

-- Float window
vim.api.nvim_set_hl(0, "NormalFloat", {
	fg = colors.on_surface,
	bg = colors.surface,
})

vim.api.nvim_set_hl(0, "FloatBorder", {
	fg = colors.on_secondary,
})

vim.api.nvim_set_hl(0, "FloatTitle", {
	fg = colors.on_primary,
	bold = true,
})

vim.opt.fillchars:append({ msgsep = "—" })
vim.api.nvim_set_hl(0, "MsgSeparator", {
	fg = colors.on_secondary,
	bg = colors.surface,
})

-- Telescope
vim.api.nvim_set_hl(0, "TelescopeBorder", {
	fg = colors.on_secondary,
	bg = colors.surface,
})

-- MiniFiles
vim.api.nvim_set_hl(0, "MiniFilesBorder", {
	fg = colors.on_secondary,
	bg = colors.surface,
})

vim.api.nvim_set_hl(0, "MiniFilesNormal", {
	fg = colors.on_secondary,
	bg = colors.surface,
})
