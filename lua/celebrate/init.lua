local M = {}
local config = require("celebrate.config")

M.config = vim.deepcopy(config.defaults)

-- Track last used URL to avoid repeats
local last_url = nil

-- Get plugin root directory
local function get_plugin_root()
  local source = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(source, ":h:h:h")
end

-- Get cache directory
local function get_cache_dir()
  local cache_home = os.getenv("XDG_CACHE_HOME")
  if cache_home and cache_home ~= "" then
    return cache_home .. "/celebrate.nvim"
  end
  return vim.fn.expand("~/.cache/celebrate.nvim")
end

-- Load celebration URLs from celebrations.lua
local function load_celebrations()
  local plugin_root = get_plugin_root()
  local celebrations_file = plugin_root .. "/celebrations.lua"

  if vim.fn.filereadable(celebrations_file) == 0 then
    return {}
  end

  local ok, urls = pcall(dofile, celebrations_file)
  if not ok or type(urls) ~= "table" then
    return {}
  end

  return urls
end

-- Generate cache filename from URL
local function url_to_cache_path(url)
  local cache_dir = get_cache_dir()
  -- Create a simple hash from URL for filename
  local hash = vim.fn.sha256(url):sub(1, 16)
  local ext = url:match("%.([^%.]+)$") or "gif"
  return cache_dir .. "/" .. hash .. "." .. ext
end

-- Check if file is cached
local function is_cached(url)
  local cache_path = url_to_cache_path(url)
  return vim.fn.filereadable(cache_path) == 1
end

-- Download URL to cache (blocking)
local function download_to_cache(url)
  local cache_dir = get_cache_dir()
  vim.fn.mkdir(cache_dir, "p")

  local cache_path = url_to_cache_path(url)

  -- Use curl to download
  local cmd = string.format("curl -sL -o '%s' '%s'", cache_path, url)
  local result = os.execute(cmd)

  if result == 0 and vim.fn.filereadable(cache_path) == 1 then
    return cache_path
  end

  return nil
end

-- Get local file path for a URL (download if needed)
local function get_local_path(url)
  -- Local file path (file:// or absolute path)
  if url:match("^file://") then
    return url:gsub("^file://", "")
  elseif url:match("^/") or url:match("^~") then
    return vim.fn.expand(url)
  end

  -- Remote URL - check cache
  if is_cached(url) then
    return url_to_cache_path(url)
  end

  -- Download and cache
  return download_to_cache(url)
end

local function play_audio(file)
  if not M.config.audio then return end
  vim.fn.jobstart({ "afplay", file }, { detach = true })
end

function M.celebrate()
  local urls = load_celebrations()

  if #urls == 0 then
    vim.notify("No celebrations found in celebrations.lua", vim.log.levels.WARN)
    return
  end

  -- Re-seed for randomness
  math.randomseed(os.time() + (vim.loop.hrtime() % 1000000))

  -- Pick a random URL, avoiding the last one if possible
  local url
  if #urls > 1 and last_url then
    -- Filter out last URL and pick from remaining
    local available = {}
    for _, u in ipairs(urls) do
      if u ~= last_url then
        table.insert(available, u)
      end
    end
    url = available[math.random(#available)]
  else
    url = urls[math.random(#urls)]
  end
  last_url = url

  -- Get local path (downloads if needed)
  vim.notify("Loading celebration...", vim.log.levels.INFO)
  local file_path = get_local_path(url)

  if not file_path then
    vim.notify("Failed to load celebration: " .. url, vim.log.levels.ERROR)
    return
  end

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
  play_audio(file_path)

  -- Run chafa in terminal buffer
  local cmd = string.format(
    "chafa --format=symbols --size=%dx%d --clear --center=on --animate=on --duration=%d '%s'",
    width - 2,
    height - 2,
    math.floor(M.config.duration_ms / 1000),
    file_path
  )
  vim.fn.termopen(cmd, {
    on_exit = function() end,
  })

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

  -- Allow closing with Escape or q
  vim.keymap.set("t", "<Esc>", close, { buffer = buf, nowait = true })
  vim.keymap.set("t", "q", close, { buffer = buf, nowait = true })
end

-- Pre-cache all celebrations in background
function M.precache()
  local urls = load_celebrations()
  local count = 0
  local total = #urls

  vim.notify(string.format("Pre-caching %d celebrations...", total), vim.log.levels.INFO)

  for _, url in ipairs(urls) do
    if not url:match("^file://") and not url:match("^/") and not url:match("^~") then
      if not is_cached(url) then
        vim.fn.jobstart({ "curl", "-sL", "-o", url_to_cache_path(url), url }, {
          on_exit = function(_, code)
            if code == 0 then
              count = count + 1
              if count == total then
                vim.notify("All celebrations cached!", vim.log.levels.INFO)
              end
            end
          end,
        })
      else
        count = count + 1
      end
    else
      count = count + 1
    end
  end
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Ensure cache directory exists
  vim.fn.mkdir(get_cache_dir(), "p")

  -- Create commands
  vim.api.nvim_create_user_command("Celebrate", M.celebrate, {
    desc = "Show a random celebration!",
  })

  vim.api.nvim_create_user_command("CelebratePrecache", M.precache, {
    desc = "Pre-download all celebration media",
  })

  -- Create keymap if configured
  if M.config.keymap then
    vim.keymap.set("n", M.config.keymap, M.celebrate, {
      desc = "Celebrate!",
    })
  end
end

return M
