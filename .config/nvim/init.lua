-- ============================================================================
-- CORE SETTINGS
-- ============================================================================
vim.opt.shortmess:append("I")

vim.opt.termguicolors = true

-- Display & UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 10

vim.opt.signcolumn = "yes"
vim.opt.showmatch = true
vim.opt.cmdheight = 1
vim.opt.showmode = false
vim.opt.pumheight = 10
vim.opt.pumblend = 10
vim.opt.conceallevel = 2
vim.opt.concealcursor = ""
vim.opt.synmaxcol = 300
vim.opt.fillchars = { eob = " " }

-- Indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Search behavior
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Files & Backup
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
	vim.fn.mkdir(undodir, "p")
end

vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = undodir
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 50
vim.opt.autoread = true
vim.opt.autowrite = false

-- General behavior
vim.opt.errorbells = false
vim.opt.backspace = "indent,eol,start"
vim.opt.autochdir = false
vim.opt.iskeyword:append("-")
vim.opt.path:append("**")
vim.opt.selection = "inclusive"
vim.opt.mouse = "a"
vim.opt.clipboard:append("unnamedplus")
vim.opt.encoding = "utf-8"

-- Cursor style
vim.opt.guicursor =
	"n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"

-- Folding (requires treesitter)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99

-- Window splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Completion & Wild menu
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.completeopt = "menuone,noinsert,noselect"

-- Performance tuning
vim.opt.diffopt:append("linematch:60")
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

-- ============================================================================
-- KEYMAPS
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Wrap-aware navigation
vim.keymap.set("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })

vim.keymap.set("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

-- Centered search results
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Horizontal Scroll
vim.keymap.set("n", "zl", function()
	vim.cmd("normal! " .. (vim.v.count1 * 25) .. "zl")
end)

vim.keymap.set("n", "zh", function()
	vim.cmd("normal! " .. (vim.v.count1 * 25) .. "zh")
end)

-- Window management
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Buffer management
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true })

-- Editing improvements
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set({ "n", "v" }, "<leader>x", '"_d', { desc = "Delete without yanking" })

-- Move lines/selections
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Indent reselect
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Utilities
vim.keymap.set("n", "<leader>pa", function() -- show file path
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Copy full file path" })

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

-- ============================================================================
-- AUTOCMDS
-- ============================================================================
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore last cursor position",
	callback = function()
		if vim.o.diff then -- except in diff mode
			return
		end

		local last_pos = vim.api.nvim_buf_get_mark(0, '"') -- {line, col}
		local last_line = vim.api.nvim_buf_line_count(0)

		local row = last_pos[1]
		if row < 1 or row > last_line then
			return
		end

		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

-- Filetype-specific settings
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})

-- Format on save (EFM only)
-- Cache EFM status per buffer to avoid repeated checks
local efm_cache = {}

vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	pattern = {
		"*.lua",
		"*.py",
		"*.go",
		"*.js",
		"*.jsx",
		"*.ts",
		"*.tsx",
		"*.json",
		"*.css",
		"*.scss",
		"*.html",
		"*.sh",
		"*.bash",
		"*.zsh",
		"*.c",
		"*.cpp",
		"*.h",
		"*.hpp",
	},
	callback = function(args)
		local buf = args.buf

		-- Skip non-file buffers
		if vim.bo[buf].buftype ~= "" then
			return
		end
		if not vim.bo[buf].modifiable then
			return
		end
		if vim.api.nvim_buf_get_name(buf) == "" then
			return
		end

		-- Check cache first
		if efm_cache[buf] == nil then
			local has_efm = false
			for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
				if c.name == "efm" then
					has_efm = true
					break
				end
			end
			efm_cache[buf] = has_efm
		end

		if not efm_cache[buf] then
			return
		end

		pcall(vim.lsp.buf.format, {
			bufnr = buf,
			timeout_ms = 2000,
			filter = function(c)
				return c.name == "efm"
			end,
		})
	end,
})

-- Clear EFM cache on LspDetach
vim.api.nvim_create_autocmd("LspDetach", {
	group = augroup,
	callback = function(args)
		efm_cache[args.buf] = nil
	end,
})

-- ============================================================================
-- PLUGINS (vim.pack)
-- ============================================================================

vim.pack.add({
	-- UI Dependencies
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",

	-- Theme & Appearance
	"https://github.com/daedlock/matugen.nvim",
	"https://github.com/nvim-lualine/lualine.nvim",

	-- Notifications
	"https://github.com/rcarriga/nvim-notify",
	"https://github.com/folke/noice.nvim",

	-- Core Editing
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},

	-- LSP Ecosystem
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/creativenull/efmls-configs-nvim",

	-- Completion
	"https://github.com/L3MON4D3/LuaSnip",
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},

	-- File Management
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/stevearc/oil.nvim",
	-- "https://github.com/nvim-tree/nvim-tree.lua",

	-- Git Integration
	"https://github.com/lewis6991/gitsigns.nvim",

	-- Quality of Life
	"https://github.com/echasnovski/mini.nvim",
	"https://github.com/nvim-mini/mini.files",
})

-- ============================================================================
-- PLUGIN CONFIGS
-- ============================================================================

-- 1. Theme: Matugen (must load first for colorscheme)
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

-- 2. Notifications & UI Enhancements
require("notify").setup({ background_colour = "#000000" })
require("noice").setup({ presets = { lsp_doc_border = true } })

-- 3. Statusline
local spinners = { "", "󰪞", "󰪟", "󰪠", "󰪡", "󰪢", "󰪣", "󰪤", "󰪥", "" }
local lsp_progress = { state = "" }

-- Helpers
local function get_filename()
	local default_icon = "󰈚"

	local path = vim.api.nvim_buf_get_name(0)
	local name = (path == "" and "Empty") or path:match("([^/\\]+)[/\\]*$")

	if name == "Empty" then
		return default_icon .. " " .. name
	end

	local ok, devicons = pcall(require, "nvim-web-devicons")

	if ok then
		local icon = devicons.get_icon(name)

		if icon then
			default_icon = icon
		end
	end

	return default_icon .. " " .. name
end

local function get_lsp_client()
	local bufnr = vim.api.nvim_get_current_buf()

	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		return "  " .. client.name
	end

	return ""
end

local function get_cwd()
	return "󰉋 " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

local function get_lsp_progress()
	return lsp_progress.state
end

-- Setup LSP Progress autocmd
local function setup_lsp_progress()
	vim.api.nvim_create_autocmd("LspProgress", {
		pattern = { "begin", "report", "end" },
		callback = function(args)
			if not args.data or not args.data.value then
				return
			end

			local data = args.data.value
			local progress = ""

			if data.percentage then
				local idx = math.max(1, math.floor(data.percentage / 10))
				local icon = spinners[idx]
				progress = icon .. " " .. data.percentage .. "%% "
			end

			local loaded_count = data.message and string.match(data.message, "^(%d+/%d+)") or ""

			local str = progress .. (data.title or "") .. " " .. (loaded_count or "")

			if data.kind == "end" then
				lsp_progress.state = ""
			else
				lsp_progress.state = str
			end

			vim.cmd("redrawstatus")
		end,
	})
end

setup_lsp_progress()

require("lualine").setup({
	options = {
		disabled_filetypes = { statusline = { "snacks_dashboard" } },
		icons_enabled = true,
		theme = require("matugen").lualine(),
		component_separators = { left = "", right = "" },
		section_separators = { left = " ", right = "" },
		always_divide_middle = true,
		globalstatus = true,
	},
	sections = {
		lualine_a = { { "mode", icon = "", separator = { left = "" }, padding = { left = 1, right = 2 } } },
		lualine_b = {
			"macro_recording",
			{ get_filename, padding = { left = 2, right = 1 } },
		},
		lualine_c = {
			{ "branch", icon = " " },
			{ "diff", symbols = { added = " ", modified = " ", removed = " " } },
		},
		lualine_x = {
			{ "diagnostics", symbols = { error = " ", warn = " ", info = " ", hint = " " } },
			get_lsp_progress,
			get_lsp_client,
		},
		lualine_y = {
			{ get_cwd, padding = { left = 1, right = 2 } },
		},
		lualine_z = {
			{ "progress", separator = { right = "" }, padding = { left = 2, right = 1 } },
		},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
})

-- Reload lualine theme when matugen updates
vim.api.nvim_create_autocmd("User", {
	pattern = "MatugenReloaded",
	callback = function()
		require("lualine").setup({ options = { theme = require("matugen").lualine() } })
	end,
})

-- 4. Treesitter
local setup_treesitter = function()
	local treesitter = require("nvim-treesitter")
	treesitter.setup({})

	local ensure_installed = {
		"vim",
		"vimdoc",
		"rust",
		"c",
		"cpp",
		"go",
		"html",
		"css",
		"javascript",
		"json",
		"lua",
		"markdown",
		"python",
		"typescript",
		"vue",
		"svelte",
		"bash",
	}

	local config = require("nvim-treesitter.config")

	local already_installed = config.get_installed()
	local parsers_to_install = {}

	for _, parser in ipairs(ensure_installed) do
		if not vim.tbl_contains(already_installed, parser) then
			table.insert(parsers_to_install, parser)
		end
	end

	if #parsers_to_install > 0 then
		treesitter.install(parsers_to_install)
	end

	local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		callback = function(args)
			if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
				vim.treesitter.start(args.buf)
			end
		end,
	})
end

setup_treesitter()

-- 5. File Explorer
require("oil").setup({
	delete_to_trash = true,
	skip_confirm_for_simple_edits = true,
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- 6. Fuzzy Finder
require("fzf-lua").setup({})

vim.keymap.set("n", "<leader>ff", function()
	require("fzf-lua").files()
end, { desc = "FZF Files" })

vim.keymap.set("n", "<leader>fg", function()
	require("fzf-lua").live_grep()
end, { desc = "FZF Live Grep" })

vim.keymap.set("n", "<leader>fb", function()
	require("fzf-lua").buffers()
end, { desc = "FZF Buffers" })

vim.keymap.set("n", "<leader>fh", function()
	require("fzf-lua").help_tags()
end, { desc = "FZF Help Tags" })

vim.keymap.set("n", "<leader>fx", function()
	require("fzf-lua").diagnostics_document()
end, { desc = "FZF Diagnostics Document" })

vim.keymap.set("n", "<leader>fX", function()
	require("fzf-lua").diagnostics_workspace()
end, { desc = "FZF Diagnostics Workspace" })

-- 7. Mini.nvim Modules
require("mini.ai").setup({})
require("mini.comment").setup({})
require("mini.move").setup({})
require("mini.surround").setup({})
require("mini.indentscope").setup({})
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
require("mini.cursorword").setup({ delay = 1000 })
require("mini.files").setup({})

vim.keymap.set("n", "<leader>e", function()
	local MiniFiles = require("mini.files")

	if MiniFiles.close() then
		return
	end

	MiniFiles.open(vim.api.nvim_buf_get_name(0), false)

	vim.defer_fn(function()
		MiniFiles.reveal_cwd()
	end, 30)
end, { desc = "Toggle MiniFiles" })

local hipatterns = require("mini.hipatterns")

hipatterns.setup({
	highlighters = {
		-- #RGB #RRGGBB #RRGGBBAA
		hex = {
			pattern = "#%x%x%x%x?%x?%x?%x?%x?",
			group = function(_, match)
				local hex = match

				-- convert #RRGGBBAA -> #RRGGBB
				if #hex == 9 then
					hex = hex:sub(1, 7)
				end

				return hipatterns.compute_hex_color_group(hex, "bg")
			end,
		},

		rgb = {
			pattern = "rgba?%([%d%s%.,]+%)",
			group = function(_, match)
				local r, g, b = match:match("rgba?%((%d+),%s*(%d+),%s*(%d+)")

				if not r then
					return nil
				end

				local hex = string.format("#%02x%02x%02x", tonumber(r), tonumber(g), tonumber(b))

				return hipatterns.compute_hex_color_group(hex, "bg")
			end,
		},
	},
})

-- 8. Git Signs
require("gitsigns").setup({
	signs = {
		add = { text = "▐" }, -- Character: ▐
		change = { text = "▐" }, -- Character: ▐
		delete = { text = "▐" }, -- Character: ▐
		topdelete = { text = "◦" }, -- Character: ◦
		changedelete = { text = "●" }, -- Character: ●
		untracked = { text = "○" }, -- Character: ○
	},
	signcolumn = true,
	current_line_blame = false,
})

vim.keymap.set("n", "]h", function()
	require("gitsigns").nav_hunk("next")
end, { desc = "Next git hunk" })

vim.keymap.set("n", "[h", function()
	require("gitsigns").nav_hunk("prev")
end, { desc = "Previous git hunk" })

vim.keymap.set("n", "<leader>hs", function()
	require("gitsigns").stage_hunk()
end, { desc = "Stage hunk" })

vim.keymap.set("n", "<leader>hr", function()
	require("gitsigns").reset_hunk()
end, { desc = "Reset hunk" })

vim.keymap.set("n", "<leader>hp", function()
	require("gitsigns").preview_hunk()
end, { desc = "Preview hunk" })

vim.keymap.set("n", "<leader>hb", function()
	require("gitsigns").blame_line({ full = true })
end, { desc = "Blame line" })

vim.keymap.set("n", "<leader>hB", function()
	require("gitsigns").toggle_current_line_blame()
end, { desc = "Toggle inline blame" })

vim.keymap.set("n", "<leader>hd", function()
	require("gitsigns").diffthis()
end, { desc = "Diff this" })

-- 9. Mason (LSP Installer)
require("mason").setup({})

-- ============================================================================
-- LSP, Linting, Formatting & Completion
-- ============================================================================

-- Diagnostic configuration
local diagnostic_signs = {
	Error = " ",
	Warn = " ",
	Hint = "",
	Info = "",
}

vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 4 },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
			[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
			[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
			[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = true,
		header = "",
		prefix = "",
		focusable = false,
		style = "minimal",
	},
})

-- Patch floating preview border for LSP hover
do
	local orig = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return orig(contents, syntax, opts, ...)
	end
end

-- LSP keymaps
local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then
		return
	end

	local bufnr = ev.buf
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- Navigation
	vim.keymap.set("n", "<leader>gd", function()
		require("fzf-lua").lsp_definitions({ jump_to_single_result = true })
	end, opts)
	vim.keymap.set("n", "<leader>gD", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "<leader>gS", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, opts)

	-- Actions
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

	-- Diagnostics
	vim.keymap.set("n", "<leader>D", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, opts)

	vim.keymap.set("n", "<leader>d", function()
		vim.diagnostic.open_float({ scope = "cursor" })
	end, opts)

	vim.keymap.set("n", "<leader>nd", function()
		vim.diagnostic.jump({ count = 1 })
	end, opts)

	vim.keymap.set("n", "<leader>pd", function()
		vim.diagnostic.jump({ count = -1 })
	end, opts)

	-- Hover
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

	-- FZF-LSP integrations
	vim.keymap.set("n", "<leader>fd", function()
		require("fzf-lua").lsp_definitions({ jump_to_single_result = true })
	end, opts)

	vim.keymap.set("n", "<leader>fr", function()
		require("fzf-lua").lsp_references()
	end, opts)

	vim.keymap.set("n", "<leader>ft", function()
		require("fzf-lua").lsp_typedefs()
	end, opts)

	vim.keymap.set("n", "<leader>fs", function()
		require("fzf-lua").lsp_document_symbols()
	end, opts)

	vim.keymap.set("n", "<leader>fw", function()
		require("fzf-lua").lsp_workspace_symbols()
	end, opts)

	vim.keymap.set("n", "<leader>fi", function()
		require("fzf-lua").lsp_implementations()
	end, opts)

	-- Organize imports (if supported)
	if client:supports_method("textDocument/codeAction", bufnr) then
		vim.keymap.set("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, 50)
		end, opts)
	end
end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

-- Diagnostic list shortcuts
vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

-- Blink.cmp completion engine
require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<CR>"] = { "accept", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },
		["<C-k>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = { menu = { auto_show = true } },
	sources = { default = { "lsp", "path", "buffer", "snippets" } },
	snippets = {
		expand = function(snippet)
			require("luasnip").lsp_expand(snippet)
		end,
	},
	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = { download = true },
	},
})

-- LSP server configurations
vim.lsp.config["*"] = {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
}

-- Individual LSP server settings
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			telemetry = { enable = false },
		},
	},
})

vim.lsp.config("pyright", {})
vim.lsp.config("bashls", {})
vim.lsp.config("ts_ls", {})
vim.lsp.config("html", {})
vim.lsp.config("cssls", {})
vim.lsp.config("gopls", {})
vim.lsp.config("clangd", {})

-- EFM (EditorConfig for Multi-language) - Formatters & Linters
do
	local luacheck = require("efmls-configs.linters.luacheck")
	local stylua = require("efmls-configs.formatters.stylua")
	local flake8 = require("efmls-configs.linters.flake8")
	local black = require("efmls-configs.formatters.black")
	local prettier_d = require("efmls-configs.formatters.prettier_d")
	local eslint_d = require("efmls-configs.linters.eslint_d")
	local fixjson = require("efmls-configs.formatters.fixjson")
	local shellcheck = require("efmls-configs.linters.shellcheck")
	local shfmt = require("efmls-configs.formatters.shfmt")
	local cpplint = require("efmls-configs.linters.cpplint")
	local clangfmt = require("efmls-configs.formatters.clang_format")
	local go_revive = require("efmls-configs.linters.go_revive")
	local gofumpt = require("efmls-configs.formatters.gofumpt")

	vim.lsp.config("efm", {
		filetypes = {
			"c",
			"cpp",
			"css",
			"go",
			"html",
			"javascript",
			"javascriptreact",
			"json",
			"jsonc",
			"lua",
			"markdown",
			"python",
			"sh",
			"typescript",
			"typescriptreact",
			"vue",
			"svelte",
		},
		init_options = { documentFormatting = true },
		settings = {
			languages = {
				c = { clangfmt, cpplint },
				go = { gofumpt, go_revive },
				cpp = { clangfmt, cpplint },
				css = { prettier_d },
				html = { prettier_d },
				javascript = { eslint_d, prettier_d },
				javascriptreact = { eslint_d, prettier_d },
				json = { eslint_d, fixjson },
				jsonc = { eslint_d, fixjson },
				lua = { luacheck, stylua },
				markdown = { prettier_d },
				python = { flake8, black },
				sh = { shellcheck, shfmt },
				typescript = { eslint_d, prettier_d },
				typescriptreact = { eslint_d, prettier_d },
				vue = { eslint_d, prettier_d },
				svelte = { eslint_d, prettier_d },
			},
		},
	})
end

-- Enable LSP servers
vim.lsp.enable({
	"lua_ls",
	"pyright",
	"bashls",
	"ts_ls",
	"html",
	"cssls",
	"gopls",
	"clangd",
	"efm",
})

-- ============================================================================
-- FLOATING TERMINAL
-- ============================================================================
local terminal_state = { buf = nil, win = nil, is_open = false }

local function FloatingTerminal()
	-- Close if already open
	if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.is_open = false
		return
	end

	-- Create buffer if needed
	if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
		terminal_state.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[terminal_state.buf].bufhidden = "hide"
	end

	-- Calculate floating window dimensions
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- Create floating window
	terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	-- Styling
	vim.wo[terminal_state.win].winblend = 0
	vim.wo[terminal_state.win].winhighlight = "Normal:FloatingTermNormal,FloatBorder:FloatingTermBorder"
	vim.api.nvim_set_hl(0, "FloatingTermNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "FloatingTermBorder", { bg = "none" })

	-- Start shell if buffer is empty
	local has_terminal = false
	local lines = vim.api.nvim_buf_get_lines(terminal_state.buf, 0, -1, false)
	for _, line in ipairs(lines) do
		if line ~= "" then
			has_terminal = true
			break
		end
	end
	if not has_terminal then
		vim.fn.termopen(os.getenv("SHELL"))
	end

	terminal_state.is_open = true
	vim.cmd("startinsert")

	-- Auto-close when leaving buffer
	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = terminal_state.buf,
		callback = function()
			if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
				vim.api.nvim_win_close(terminal_state.win, false)
				terminal_state.is_open = false
			end
		end,
		once = true,
	})
end

-- Terminal keymaps
vim.keymap.set("n", "<leader>t", FloatingTerminal, { noremap = true, silent = true, desc = "Toggle floating terminal" })
vim.keymap.set("t", "<Esc>", function()
	if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.is_open = false
	end
end, { noremap = true, silent = true, desc = "Close floating terminal" })

-- Terminal behavior autocmds
vim.api.nvim_create_autocmd("TermClose", {
	group = augroup,
	callback = function()
		if vim.v.event.status == 0 then
			vim.api.nvim_buf_delete(0, {})
		end
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	group = augroup,
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
	end,
})
