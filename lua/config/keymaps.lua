-- File: ~/.config/nvim/lua/config/keymaps.lua
-- This file is loaded globally by LazyVim for all keymaps.
--

vim.keymap.set("n", "<leader>r", "<cmd>CompilerOpen<cr>", { desc = "Open Compiler", silent = true })

vim.keymap.set(
  "n",
  "<leader>R",
  "<cmd>CompilerStop<cr><cmd>CompilerRedo<cr>",
  { desc = "Restart Compiler", silent = true }
)

vim.keymap.set("n", "<leader>rt", "<cmd>CompilerToggleResults<cr>", { desc = "Toggle Compiler Results", silent = true })
