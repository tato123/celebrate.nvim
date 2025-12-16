local M = {}
local config = require("celebrate.config")

M.config = vim.deepcopy(config.defaults)

local function get_media_files()
  local files = {}
  for _, ext in ipairs(M.config.extensions) do
    local pattern = M.config.media_dir .. "/*." .. ext
    local matches = vim.fn.glob(pattern, false, true)
    for _, f in ipairs(matches) do
      table.insert(files, f)
    end
  end
  return files
end

local function play_audio(file)
  if not M.config.audio then return end
  -- macOS audio playback (runs in background)
  vim.fn.jobstart({ "afplay", file }, { detach = true })
end

function M.celebrate()
  local files = get_media_files()

  if #files == 0 then
    vim.notify("No celebration files in " .. M.config.media_dir, vim.log.levels.WARN)
    return
  end

  local choice = files[math.random(#files)]

  -- Calculate dimensions
  local width = math.floor(vim.o.columns * M.config.width_ratio)
  local height = math.floor(vim.o.lines * M.config.height_ratio)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- Create floating window
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = " Celebration! ",
    title_pos = "center",
  })

  -- Play audio if it's a video with audio track
  play_audio(choice)

  -- Run chafa in terminal buffer
  local cmd = string.format(
    "chafa --format=kitty --size=%dx%d --animate=on --duration=%d %s; exit",
    width - 2,
    height - 2,
    math.floor(M.config.duration_ms / 1000),
    vim.fn.shellescape(choice)
  )
  vim.fn.termopen(cmd)
  vim.cmd("startinsert")

  -- Close handler
  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  -- Auto-close after duration
  vim.defer_fn(close, M.config.duration_ms)

  -- Allow closing with Escape
  vim.keymap.set("t", "<Esc>", close, { buffer = buf, nowait = true })
  vim.keymap.set("t", "q", close, { buffer = buf, nowait = true })
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Create command
  vim.api.nvim_create_user_command("Celebrate", M.celebrate, {
    desc = "Show a random celebration!",
  })

  -- Create keymap if configured
  if M.config.keymap then
    vim.keymap.set("n", M.config.keymap, M.celebrate, {
      desc = "Celebrate!",
    })
  end
end

return M
