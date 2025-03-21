-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.api.nvim_set_keymap("i", "kj", "<Esc>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<leader>rcc", ":!cargo check", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>rcr", ":!cargo run", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>rcrr", ":!cargo run --release", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>rcb", ":!cargo build", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>rcbr", ":!cargo build --release", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>rcf", ":!cargo fmt", { noremap = true, silent = true })
