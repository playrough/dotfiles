-- telescope: pickers; <leader>s* keymaps in lua/plugins/keymaps.lua.
-- fzf-native is rebuilt after every install/update.

local function build_fzf_native(path)
  vim.notify("Building telescope-fzf-native...", vim.log.levels.INFO)
  local res = vim.system({ "make" }, { cwd = path }):wait()
  if res.code ~= 0 then
    vim.notify("telescope-fzf-native build failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
    return false
  end
  return true
end

-- Specs are installed centrally in plugins/init.lua, so this only catches later
-- installs/updates; the fallback near the bottom rebuilds if the first one was missed.
local augroup = vim.api.nvim_create_augroup("UserTelescope", { clear = true })
vim.api.nvim_create_autocmd("PackChanged", {
  group = augroup,
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "telescope-fzf-native.nvim" and (kind == "install" or kind == "update") then
      if not ev.data.active then
        vim.cmd.packadd("telescope-fzf-native.nvim")
      end
      build_fzf_native(ev.data.path)
    end
  end,
})

require("telescope").setup({
  defaults = {
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        prompt_position = "bottom",
        width = 0.8,
        height = 0.8,
        preview_width = 0.5,
        prompt_title = "",
        results_title = "",
        preview_title = "",
      },
    },
    path_display = { "filename_first" },
    sorting_strategy = "descending",
    prompt_prefix = "",
    entry_prefix = "  ",
    prompt_title = false,
    results_title = false,
    preview_title = false,
  },
  pickers = {
    find_files = { prompt_title = "", results_title = "", preview_title = "" },
    live_grep = { prompt_title = "", results_title = "", preview_title = "" },
    buffers = { prompt_title = "", results_title = "", preview_title = "" },
    help_tags = { prompt_title = "", results_title = "", preview_title = "" },
    git_status = { prompt_title = "", results_title = "", preview_title = "" },
    diagnostics = { prompt_title = "", results_title = "", preview_title = "" },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
    ["ui-select"] = {
      require("telescope.themes").get_dropdown({}),
    },
    frecency = {
      show_filter_column = false,
      hide_current_buffer = true,
      preceding = "opened",
      prompt_title = "",
      results_title = "",
      preview_title = "",
    },
  },
})

-- PackChanged only fires on install/update, so rebuild here if a build was ever missed
local fzf_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/telescope-fzf-native.nvim"
local fzf_ok = vim.uv.fs_stat(fzf_path .. "/build/libfzf.so") ~= nil or build_fzf_native(fzf_path)
if fzf_ok then
  require("telescope").load_extension("fzf")
end
require("telescope").load_extension("ui-select")
require("telescope").load_extension("frecency")
