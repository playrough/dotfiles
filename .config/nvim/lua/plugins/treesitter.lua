-- treesitter: parsers, highlighting, folding (foldexpr set in lua/config/options.lua).

local treesitter = require("nvim-treesitter")
treesitter.setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

local ensure_installed = {
  -- editor
  "lua",
  "vim",
  "vimdoc",
  "query",

  -- shell
  "bash",
  "zsh",

  -- config / data
  "toml",
  "yaml",
  "json",
  "xml",
  "kitty",
  "gitignore",
  "ron",

  -- docs
  "markdown",
  "markdown_inline",

  -- web
  "html",
  "css",
  "scss",
  "javascript",
  "typescript",
  "tsx",

  -- systems
  "c",
  "cpp",
  "rust",
  "cmake",
  "python",
  "regex",
}

local function install_parsers()
  treesitter.install(ensure_installed)
end

-- Wait for mason-tool-installer to finish before compiling parsers
if vim.fn.executable("tree-sitter") == 1 then
  install_parsers()
else
  vim.api.nvim_create_autocmd("User", {
    pattern = "MasonToolsUpdateCompleted",
    once = true,
    callback = install_parsers,
  })
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
