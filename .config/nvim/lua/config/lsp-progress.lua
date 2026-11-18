-- Single "LSP" progress message aggregating every LSP progress token.
-- The token that is furthest along wins, so the percentage only moves forward
-- within a phase even when servers run several progress bars in parallel.
local jobs = {} -- token -> { percent, title, reports }
local message_id, last_percent, last_title = nil, nil, nil

local BAR_WIDTH = 30
local HOLD_MS = 2000 -- how long the full 100% bar stays visible
local finish_timer = vim.uv.new_timer()

-- The bar is drawn from the real percentage, so it is only full at 100%.
local function bar(percent)
  percent = math.max(0, math.min(100, tonumber(percent) or 0))
  local filled = math.floor(percent * BAR_WIDTH / 100) -- floor: 99% is not full
  return "[" .. string.rep("=", filled) .. string.rep(" ", BAR_WIDTH - filled) .. "]"
end

-- "LSP:  45% Indexing"
local function headline(percent, title)
  local line = ("LSP: %3d%%"):format(percent)
  return title ~= nil and title ~= "" and (line .. " " .. title) or line
end

-- Title first, bar underneath.
local function progress_text(percent, title)
  percent = math.max(0, math.min(100, math.floor(tonumber(percent) or 0)))
  return headline(percent, title) .. "\n" .. bar(percent)
end

-- ui2 caches the msg window width and never shrinks it. Refit it to the text
-- it currently holds, otherwise the frame stays as wide as the bar.
local function fit_msg_window()
  local ok, ui = pcall(require, "vim._core.ui2")
  local win = ok and ui.wins and ui.wins.msg
  local buf = ok and ui.bufs and ui.bufs.msg
  if not win or not buf or not vim.api.nvim_win_is_valid(win) or not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local width = 1
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  if ui.msg and ui.msg.msg then
    ui.msg.msg.width = width -- internal cache, must match the window width
  end
  pcall(vim.api.nvim_win_set_width, win, width)
end

local function echo(text, status)
  message_id = vim.api.nvim_echo({ { text } }, false, {
    id = message_id,
    source = "lsp-progress",
    status = status,
    kind = "progress",
  })
  fit_msg_window()
end

local function finish(title)
  echo(headline(100, title), "success")
  last_percent, last_title = nil, nil
end

-- Keep the full bar for HOLD_MS, then replace it with the final message.
local function finish_later(title)
  if not finish_timer then
    return
  end
  finish_timer:stop()
  finish_timer:start(HOLD_MS, 0, vim.schedule_wrap(function()
    if next(jobs) == nil then
      finish(title)
    end
  end))
end

local function render()
  local best_percent, best_title = nil, nil
  for _, job in pairs(jobs) do
    -- Ignore tokens that have not reported anything yet: short tasks such as
    -- lua_ls semantic tokens are begin + end only and would just flash.
    if (job.reports > 0 or job.percent > 0) and (best_percent == nil or job.percent > best_percent) then
      best_percent, best_title = job.percent, job.title
    end
  end

  if best_percent == nil then
    return
  end

  -- Another token may finish first; keep the number from going backwards.
  if best_title == last_title and last_percent and best_percent < last_percent then
    best_percent = last_percent
  end

  -- Skip unchanged output: avoids clear + redraw of the message window.
  if best_percent == last_percent and best_title == last_title then
    return
  end
  last_percent, last_title = best_percent, best_title

  echo(progress_text(best_percent, best_title), "running")
end

vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(args)
    local params = args.data and args.data.params
    if not params or not params.value then
      return
    end

    local value = params.value
    local token = tostring(params.token or "default")
    local title = value.title or value.message or ""

    if value.kind == "end" then
      local job = jobs[token]
      jobs[token] = nil

      if next(jobs) ~= nil then
        render()
        return
      end

      -- Short begin+end tasks have no progress to show; only wrap up a message
      -- that an earlier phase left behind.
      if (job == nil or job.reports == 0) and last_percent == nil then
        return
      end

      local done_title = (title ~= "" and title) or last_title or ""
      echo(progress_text(100, done_title), "running") -- force the full bar
      finish_later(done_title)
      return
    end

    local job = jobs[token]
    if job == nil then
      job = { percent = 0, title = title, reports = 0 }
      jobs[token] = job
    end

    job.title = title
    job.percent = value.percentage or 0
    if value.kind == "report" then
      job.reports = job.reports + 1
    end

    render()
  end,
})
