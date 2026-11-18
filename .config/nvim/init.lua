require("config")
require("plugins")
-- Load theme after plugins so colorschemes/plugin setup cannot override it.
require("config.theme")
