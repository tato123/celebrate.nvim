local M = {}

M.defaults = {
  media_dir = vim.fn.expand("~/celebrations"),
  duration_ms = 4000,
  width_ratio = 0.5,
  height_ratio = 0.5,
  audio = true,
  keymap = "<leader>yay",
  extensions = { "gif", "mp4", "webm", "png", "jpg" },
}

return M
