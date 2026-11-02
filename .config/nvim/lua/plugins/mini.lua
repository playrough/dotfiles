vim.pack.add({
  "https://github.com/echasnovski/mini.nvim",
  "https://github.com/nvim-mini/mini.files",
})

require("mini.ai").setup({})
require("mini.comment").setup({})
require("mini.move").setup({})
require("mini.surround").setup({})
require("mini.indentscope").setup({})
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
require("mini.cursorword").setup({ delay = 1000 })
require("mini.files").setup({})

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


local hipatterns = require("mini.hipatterns")

hipatterns.setup({
  highlighters = {
    -- #RGB #RRGGBB #RRGGBBAA
    hex = {
      pattern = "#%x%x%x%x?%x?%x?%x?%x?",
      group = function(_, match)
        local hex = match

        -- convert #RRGGBBAA -> #RRGGBB
        if #hex == 9 then
          hex = hex:sub(1, 7)
        end

        return hipatterns.compute_hex_color_group(hex, "bg")
      end,
    },

    rgb = {
      pattern = "rgba?%([%d%s%.,]+%)",
      group = function(_, match)
        local r, g, b = match:match("rgba?%((%d+),%s*(%d+),%s*(%d+)")

        if not r then
          return nil
        end

        local hex = string.format("#%02x%02x%02x", tonumber(r), tonumber(g), tonumber(b))

        return hipatterns.compute_hex_color_group(hex, "bg")
      end,
    },
  },
})
