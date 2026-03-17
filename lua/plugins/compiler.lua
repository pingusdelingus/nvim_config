if true then
  return {}
else
  return {
    { -- The main compiler plugin
      "Zeioth/compiler.nvim",
      cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
      dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
      opts = {},
      -- This is where we put your new keymaps!
      keys = {
        { "<leader>r", "<cmd>CompilerOpen<cr>", desc = "Open Compiler" },
        { "<leader>R", "<cmd>CompilerStop<cr><cmd>CompilerRedo<cr>", desc = "Restart Compiler" },
        { "<leader>rt", "<cmd>CompilerToggleResults<cr>", desc = "Toggle Compiler Results" },
      },
    },
    { -- The task runner (Overseer)
      "stevearc/overseer.nvim",
      commit = "6271cab7ccc4ca840faa93f54440ffae3a3918bd",
      cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
      opts = {
        task_list = {
          direction = "bottom",
          min_height = 25,
          max_height = 25,
          default_detail = 1,
        },
      },
    },
  }
end
