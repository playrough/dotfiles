local M = {}

function M.source_matugen()
  local matugen_path = os.getenv 'HOME' .. '/.config/nvim/generated.lua'
  local file, err = io.open(matugen_path, 'r')

  if err ~= nil then
    vim.cmd 'colorscheme default'
    vim.print 'A matugen style file was not found, but the colorscheme will dynamically change if matugen runs!'
  else
    dofile(matugen_path)
    io.close(file)
  end
end

function M.auxiliary_function()
  -- Load new colors
  M.source_matugen()

  -- Reload your lualine config
  dofile(os.getenv 'HOME' .. '/.config/nvim/config/plugins/lualine-nvim.lua')

  -- Additional highlight settings
  vim.api.nvim_set_hl(0, 'Comment', { italic = true })
end

function M.setup()
  -- Initial load
  M.source_matugen()

  -- Autocmd for SIGUSR1
  vim.api.nvim_create_autocmd('Signal', {
    pattern = 'SIGUSR1',
    callback = M.auxiliary_function,
  })
end

return M
