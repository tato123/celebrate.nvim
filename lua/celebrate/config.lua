local M = {}

-- Get XDG config dir or fallback to ~/.config
local function get_global_media_dir()
  local xdg_config = os.getenv("XDG_CONFIG_HOME")
  if xdg_config and xdg_config ~= "" then
    return xdg_config .. "/celebrate.nvim"
  end
  return vim.fn.expand("~/.config/celebrate.nvim")
end

M.defaults = {
  -- Global config directory (XDG compliant)
  global_media_dir = get_global_media_dir(),
  -- Local directory name (relative to cwd)
  local_media_dir = "celebrate",
  -- Check local directory first, then global
  use_local = true,
  duration_ms = 4000,
  width_ratio = 0.5,
  height_ratio = 0.5,
  audio = true,
  keymap = "<leader>yay",
  extensions = { "gif", "mp4", "webm", "png", "jpg" },
}

return M
