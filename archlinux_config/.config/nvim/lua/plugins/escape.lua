return {
  "max397574/better-escape.nvim",
  event = "InsertEnter", -- 按需加载（进入插入模式时加载）
  config = function()
    require("better_escape").setup({
      mapping = { "kj" }, -- 设置触发退出的组合键
      timeout = 300, -- 触发时间窗口（毫秒）
      clear_empty_lines = false, -- 保留空行的编辑状态
      keys = "<Esc>", -- 显式指定 Esc 键行为（避免冲突）
    })
  end,
}
