-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.api.nvim_set_keymap("i", "kj", "<Esc>", { noremap = true, silent = true, desc = "映射返回键" })
vim.api.nvim_set_keymap(
  "n",
  "<leader>o",
  ":!xdg-open %<CR>",
  { noremap = true, silent = true, desc = "用系统程序打开当前文件" }
)
