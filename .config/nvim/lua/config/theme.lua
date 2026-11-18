-- Custom highlights: colors from colors.json, disable undercurl, clear diagnostic virtual text background.
-- Loaded after require("plugins") in init.lua so colorschemes cannot override it.

local M = {}

-- colors.json is re-read on every apply(), so matugen updates need no restart.
local colors_path = vim.fn.stdpath("config") .. "/colors.json"

local function load_colors()
  local file = io.open(colors_path, "r")
  if not file then
    return {}
  end

  local content = file:read("*a")
  file:close()

  local ok, colors = pcall(vim.json.decode, content)
  if not ok or type(colors) ~= "table" then
    return {}
  end

  return colors
end

local function apply_highlights(colors)
  local groups = {
    -- tiny-cmdline
    TinyCmdlineBorder = { fg = colors.on_secondary },
    TinyCmdlineNormal = { fg = colors.on_surface, bg = colors.surface },

    -- blink.cmp
    BlinkCmpMenu = { fg = colors.on_surface, bg = colors.surface },
    BlinkCmpMenuBorder = { fg = colors.on_secondary },
    BlinkCmpMenuSelection = { fg = colors.primary, bg = colors.surface_container_low },
    BlinkCmpScrollBarThumb = { bg = colors.on_secondary },
    BlinkCmpGhostText = { fg = colors.outline_variant },
    BlinkCmpDoc = { fg = colors.on_surface, bg = colors.surface },
    BlinkCmpDocBorder = { fg = colors.on_secondary },
    BlinkCmpDocSeparator = { fg = colors.on_secondary },

    -- floating windows
    NormalFloat = { fg = colors.on_surface, bg = colors.surface },
    FloatBorder = { fg = colors.on_secondary },
    FloatTitle = { fg = colors.on_primary, bold = true },

    -- message separator
    MsgSeparator = { fg = colors.on_secondary, bg = colors.surface },

    -- telescope
    TelescopeBorder = { fg = colors.on_secondary, bg = colors.surface },

    -- mini.files
    MiniFilesBorder = { fg = colors.on_secondary, bg = colors.surface },
    MiniFilesNormal = { fg = colors.primary, bg = colors.surface },
    MiniFilesTitle = { fg = colors.primary, bg = colors.surface },
    MiniFilesTitleFocused = { fg = colors.tertiary, bg = colors.surface },

    -- -- message
    WarningMsg = { fg = colors.cyan },
    MoreMsg = { fg = colors.blue },
    OkMsg = { fg = colors.green },
    ErrorMsg = { fg = colors.error },
  }

  for name, hl in pairs(groups) do
    vim.api.nvim_set_hl(0, name, hl)
  end
end

local function disable_undercurl()
  for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    if hl.undercurl and not hl.link then
      hl.undercurl = false
      hl.underline = true
      vim.api.nvim_set_hl(0, name, hl)
    end
  end
end

local diagnostic_virtual_groups = {
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

local function clear_diagnostic_bg()
  for _, group in ipairs(diagnostic_virtual_groups) do
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    vim.api.nvim_set_hl(0, group, {
      fg = hl.fg,
      bg = "NONE",
      italic = hl.italic,
    })
  end
end

function M.apply()
  local colors = load_colors()
  apply_highlights(colors)
  disable_undercurl()
  clear_diagnostic_bg()
end

-- Re-apply on colorscheme change or when matugen reloads colors.
local augroup = vim.api.nvim_create_augroup("UserTheme", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", { group = augroup, callback = M.apply })
vim.api.nvim_create_autocmd("User", {
  group = augroup,
  pattern = "MatugenReloaded",
  callback = M.apply,
})

M.apply()

return M
