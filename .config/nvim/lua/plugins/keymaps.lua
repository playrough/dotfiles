-- Plugin keymaps. Core Neovim keymaps live in lua/config/keymaps.lua.

-- LSP -----------------------------------------------------------------------
local lsp_augroup = vim.api.nvim_create_augroup("UserLspAttach", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_augroup,
  callback = function(args)
    local bufnr = args.buf
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map("n", "K", vim.lsp.buf.hover, "LSP Hover")
    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    map("n", "gr", vim.lsp.buf.references, "References")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
  end,
})

-- Format: conform for CLI formatters, LSP as fallback. Global so buffers without
-- an attached server (e.g. plain markdown/sh) can still be formatted.
vim.keymap.set({ "n", "v" }, "<leader>f", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer/selection" })

-- MiniFiles -----------------------------------------------------------------
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

-- Telescope -----------------------------------------------------------------
vim.keymap.set("n", "<leader>sf", "<cmd>Telescope find_files<cr>", { silent = true, desc = "Find files" })
vim.keymap.set(
  "n",
  "<leader>sr",
  '<cmd>Telescope frecency workspace=CWD path_display={"filename_first"}<cr>',
  { silent = true, desc = "Recent files (frecency)" }
)
vim.keymap.set("n", "<leader>sg", "<cmd>Telescope live_grep<cr>", { silent = true, desc = "Live grep" })
vim.keymap.set("n", "<leader>sb", "<cmd>Telescope buffers<cr>", { silent = true, desc = "Buffers" })
vim.keymap.set("n", "<leader>sd", "<cmd>Telescope diagnostics<cr>", { silent = true, desc = "Diagnostics" })
-- help_tags uses <leader>s? so <leader>sh stays free for horizontal split (see config/keymaps.lua).
vim.keymap.set("n", "<leader>s?", "<cmd>Telescope help_tags<cr>", { silent = true, desc = "Help tags" })
vim.keymap.set("n", "<leader>su", "<cmd>Telescope git_status<cr>", { silent = true, desc = "Git status" })
vim.keymap.set("n", "<leader>s.", "<cmd>Telescope resume<cr>", { silent = true, desc = "Resume last picker" })

-- gitsigns ------------------------------------------------------------------
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
