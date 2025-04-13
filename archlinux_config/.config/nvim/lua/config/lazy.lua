local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "plugins" },
  },
  defaults = {
    lazy = true,
    version = "*",
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true,
    notify = true,
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit", -- 增强 % 键的匹配能力
        -- "matchparen", -- 高亮匹配的括号/引号
        "netrwPlugin", -- 内置文件浏览器
        "tarPlugin",
        "tohtml", -- 将代码转换为 HTML
        "tutor", -- Neovim 内置教程
        "zipPlugin",
        "2match",
        "getscriptPlugin",
        "manPlugin", -- 内置Man命令
        "vimballPlugin",
        "logiPat", -- 逻辑模式匹配
        -- "spellfile", -- 拼写检查字典管理
      },
    },
  },
})
