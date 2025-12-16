-- Prevent loading twice
if vim.g.loaded_celebrate then
  return
end
vim.g.loaded_celebrate = true

-- Plugin will be initialized when user calls require("celebrate").setup()
