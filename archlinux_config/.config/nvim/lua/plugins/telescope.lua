return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>r",
        function()
          require("telescope.builtin").registers()
        end,
        desc = "查看寄存器内容并选择",
      },
    },
  },
}
