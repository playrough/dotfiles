-- Plugin management with vim.pack; :PackClean removes plugins no longer declared.

local M = {}

function M.cleanup()
  local unused = {}

  for _, plugin in ipairs(vim.pack.get()) do
    if not plugin.active then
      table.insert(unused, plugin.spec.name)
    end
  end

  if #unused == 0 then
    vim.notify("No unused plugins.", vim.log.levels.INFO)
    return
  end

  local choice = vim.fn.confirm("Remove unused plugins?\n\n" .. table.concat(unused, "\n"), "&Yes\n&No", 2)

  if choice == 1 then
    vim.pack.del(unused)
  end
end

vim.api.nvim_create_user_command("PackClean", M.cleanup, {
  desc = "Remove plugins that are no longer specified",
})

return M
