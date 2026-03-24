-- File: ~/.config/nvim/lua/config/keymaps.lua
-- This file is loaded globally by LazyVim for all keymaps.
--

--vim.keymap.set("n", "<leader>r", "<cmd>CompilerOpen<cr>", { desc = "Open Compiler", silent = true })
--
--vim.keymap.set(
--  "n",
--  "<leader>R",
--  "<cmd>CompilerStop<cr><cmd>CompilerRedo<cr>",
--  { desc = "Restart Compiler", silent = true }
--)

--vim.keymap.set("n", "<leader>rt", "<cmd>CompilerToggleResults<cr>", { desc = "Toggle Compiler Results", silent = true })
--
--
-- vim.keymap.del("n", "<leader>c")
--
vim.api.nvim_create_autocmd("CursorMoved", {
  group = vim.api.nvim_create_augroup("QuickfixAutoJump", { clear = true }),
  pattern = "quickfix",
  callback = function()
    -- Only jump if the window is open and we are in it
    if vim.fn.getwininfo(vim.fn.win_getid())[1].quickfix == 1 then
      -- 'pcall' prevents errors if the line isn't a valid error
      -- 'vim.cmd.cc' jumps to the current error under cursor
      -- 'vim.cmd.wincmd("p")' jumps back to the quickfix window immediately
      pcall(function()
        vim.cmd("cc " .. vim.fn.line("."))
        vim.cmd("wincmd p")
      end)
    end
  end,
})
