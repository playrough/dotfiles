-- Config load order: options -> autocmds -> diagnostics -> pack -> keymaps.
-- Plugin keymaps live in lua/plugins/keymaps.lua.
require("config.options")
require("config.autocmds")
require("config.diagnostics")
require("config.pack")
require("config.keymaps")
require("config.lsp-progress")

