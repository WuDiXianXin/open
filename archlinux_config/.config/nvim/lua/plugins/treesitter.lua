return {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  ft = { "lua", "rust", "markdown", "bash", "sh", "vim" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    "nvim-treesitter/playground",
  },

  keys = {
    { "<leader>th", "<cmd>TSBufToggle highlight<cr>", desc = "语法高亮开关" },
    {
      "<leader>tc",
      function()
        vim.o.foldmethod = (vim.o.foldmethod == "expr") and "manual" or "expr"
      end,
      desc = "代码折叠开关",
    },
    { "<leader>tp", "<cmd>TSPlaygroundToggle<cr>", desc = "语法树调试器" },
  },

  opts = {
    ensure_installed = {
      "lua",
      "rust",
      "markdown",
      "bash",
      "vimdoc",
      "query",
    },
    sync_install = false,
    auto_install = true,

    highlight = {
      enable = true,
      disable = { "help", "vim" },
      additional_vim_regex_highlighting = false,
    },

    indent = {
      enable = true,
      disable = { "python" },
    },

    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<CR>",
        node_incremental = "<C-CR>",
        scope_incremental = "<Tab>",
        node_decremental = "<S-Tab>",
      },
    },

    textobjects = {
      select = {
        enable = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = { ["]f"] = "@function.outer" },
        goto_previous_start = { ["[f"] = "@function.outer" },
      },
    },

    playground = {
      enable = true,
      updatetime = 25,
    },
  },

  config = function(_, opts)
    vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
      group = vim.api.nvim_create_augroup("TreesitterFold", { clear = true }),
      callback = function()
        -- 获取当前缓冲区的总行数
        local line_count = vim.fn.line("$")
        -- 安全计算折叠层级（修复语法错误并优化逻辑）
        local fold_level = math.min(
          math.max(math.floor(line_count / 100), 1), -- 使用Lua标准整除运算，并确保最小层级为1
          20 -- 最大不超过20
        )
        -- 处理空文件的特殊情况
        if line_count == 0 then
          fold_level = 1 -- 空文件默认折叠层级
        end
        -- 设置折叠参数
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
        vim.wo.foldlevel = fold_level
      end,
    })
    -- 核心配置
    require("nvim-treesitter.configs").setup(opts)
  end,

  -- 新增清理函数（LazyVim 特性）
  cond = function()
    return not vim.g.started_by_firenvim
  end,
}
