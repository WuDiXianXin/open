-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.api.nvim_set_keymap("i", "kj", "<Esc>", { noremap = true, silent = true, desc = "映射返回键" })
vim.api.nvim_set_keymap(
  "n",
  "<leader>cp",
  ":normal! ggVGp<CR>:p<CR>",
  { noremap = true, silent = true, desc = "替换全文内容" }
)
vim.keymap.set("n", "<A-k>", ":m-2<CR>", { noremap = true, silent = true, desc = "Swap line up" })
vim.keymap.set("n", "<A-j>", ":m+<CR>", { noremap = true, silent = true, desc = "Swap line down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move lines up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move lines down" })
vim.api.nvim_set_keymap(
  "n",
  "<leader>bc",
  ":bufdo bwipeout<cr>",
  { noremap = true, silent = true, desc = "彻底删除缓冲区" }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>mdp",
  ":MarkdownPreviewToggle<cr>",
  { noremap = true, silent = true, desc = "映射返回键" }
)
