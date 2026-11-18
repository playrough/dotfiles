-- Single "LSP" progress message aggregating every LSP progress token.
-- The token that is furthest along wins, so the percentage only moves forward
-- within a phase even when servers run several progress bars in parallel.
local jobs = {} -- token -> { percent, title, reports }
local message_id, last_percent, last_title = nil, nil, nil

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

  message_id = vim.api.nvim_echo({ { best_title } }, false, {
    id = message_id,
    percent = math.min(best_percent, 100),
    source = "lsp-progress",
    status = "running",
    title = "LSP",
    kind = "progress",
  })
end

local function finish(title)
  message_id = vim.api.nvim_echo({ { title } }, false, {
    id = message_id,
    percent = 100,
    source = "lsp-progress",
    status = "success",
    title = "LSP",
    kind = "progress",
  })
  last_percent, last_title = nil, nil
end

vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(args)
    local params = args.data and args.data.params

    if not params then
      return
    end

    local value = params.value
    if not value then
      return
    end

    local token = tostring(params.token or "default")
    local title = value.title or value.message or ""

    if value.kind == "end" then
      local job = jobs[token]
      jobs[token] = nil

      if next(jobs) ~= nil then
        render()
        return
      end

      -- Ignore short tasks that never reported progress (e.g. lua_ls semantic
      -- tokens): they would only flash a "100%" message between phases.
      if job == nil or job.reports == 0 then
        return
      end

      finish(title ~= "" and title or last_title or "")
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
