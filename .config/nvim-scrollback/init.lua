-- init.lua cho kitty scrollback

vim.opt.runtimepath = vim.env.VIMRUNTIME
vim.opt.packpath = vim.env.VIMRUNTIME

vim.o.number = false
vim.o.relativenumber = false
vim.o.signcolumn = 'no'
vim.o.statusline = ''
vim.o.laststatus = 0
vim.o.showmode = false
vim.o.cmdheight = 1
vim.o.swapfile = false
vim.o.buftype = 'nofile'
vim.o.wrap = false

vim.opt.termguicolors = true
vim.cmd [[
  set laststatus=0
  hi clear
  hi Normal guibg=NONE ctermbg=NONE
]]

vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
