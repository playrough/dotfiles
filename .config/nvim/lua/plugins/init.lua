-- Load plugins; plugins.keymaps runs last so every plugin is ready.
-- Specs live in lua/plugins/specs.lua and are installed in one batch.
vim.pack.add(require("plugins.specs"))

require("plugins.lsp")
require("plugins.conform")
require("plugins.completions")
require("plugins.treesitter")
require("plugins.matugen")
require("plugins.cmdline")
require("plugins.telescope")
require("plugins.git")
require("plugins.lualine")
require("plugins.mini")
require("plugins.keymaps")
