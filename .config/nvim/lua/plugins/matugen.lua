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
})

local function clear_diagnostic_bg()
  local groups = {
    "DiagnosticVirtualTextError",
    "DiagnosticVirtualTextWarn",
    "DiagnosticVirtualTextInfo",
    "DiagnosticVirtualTextHint",
    "DiagnosticVirtualTextOk",
    "DiagnosticVirtualLinesError",
    "DiagnosticVirtualLinesWarn",
    "DiagnosticVirtualLinesInfo",
    "DiagnosticVirtualLinesHint",
    "DiagnosticVirtualLinesOk",
  }

  for _, group in ipairs(groups) do
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    vim.api.nvim_set_hl(0, group, {
      fg = hl.fg,
      bg = "NONE",
      italic = hl.italic,
    })
  end
end

vim.api.nvim_create_autocmd({ "ColorScheme", "User" }, {
  pattern = { "matugen", "MatugenReloaded" },
  callback = clear_diagnostic_bg,
})

vim.cmd.colorscheme("matugen")
