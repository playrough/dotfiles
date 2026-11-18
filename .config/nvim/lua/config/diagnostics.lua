-- Diagnostic UI: virtual text, signs, underline, float.

local diagnostic_signs = {
  Error = "󰅚 ",
  Warn = "󰗖 ",
  Hint = " ",
  Info = "󰋽 ",
}

vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    prefix = function(_, i, total)
      return i == total and "" or ""
    end,
  },
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
