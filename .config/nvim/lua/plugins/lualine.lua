-- lualine: statusline with matugen theme

vim.pack.add({
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lualine/lualine.nvim",
})

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
    return " " .. client.name
  end

  return ""
end

local function get_cwd()
  return "󰉋 " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

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

-- Reload theme when matugen reloads colors.
vim.api.nvim_create_autocmd("User", {
  pattern = "MatugenReloaded",
  callback = function()
    require("lualine").setup({ options = { theme = require("matugen").lualine() } })
  end,
})
