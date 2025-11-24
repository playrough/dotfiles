return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        local configs = require("nvim-treesitter.configs")
        configs.setup({
            highlight = {
                enable = true,
            },
            indent = {
                enable = true
            },
            autotage = { enable = true },
            ensure_installed = {
                "lua",
                "tsx",
                "typescript",
                "php",
                "python",
                "c",
                "bash",
                "html",
                "css",
                "javascript",
                "json",
                "jsonc",
                "hyprlang",
                "bash"
            },
            auto_install = false,
        })
    end
}
