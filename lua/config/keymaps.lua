-- File: ~/.config/nvim/lua/config/keymaps.lua
-- This file is loaded globally by LazyVim for all keymaps.

local keymap = vim.keymap.set

-- Recommended global setting for easier terminal workflow
-- This is good for any built-in terminal buffer you might open
vim.keymap.set("t", "<Esc>", "<C-\\><C-N>", {
  desc = "Exit terminal mode and go into normal mode",
})

-- =====================================================================
-- C-RUNNER KEYMAP (<leader>r) - INTERACTIVE (using ToggleTerm)
-- This version uses :make (via makeprg) to compile.
-- =====================================================================
keymap("n", "<leader>r", function()
  -- 1. Check filetype
  if vim.bo.filetype ~= "c" or vim.bo.filetype ~= "cpp" then
    print("not a C/C++ file. Aborting")
    return
  end

  -- 2. Get the filenames CORRECTLY
  --    We use Lua's vim.fn.expand() to get the file paths, as '%' won't work here.
  local filename_full_path = vim.fn.expand("%:p") -- e.g., /home/user/file.c
  --    Create output name based on the current file's name, e.g., ./file.out
  local output_name = "./" .. vim.fn.expand("%:t:r") .. ".out"

  -- 3. Save the current file first
  vim.cmd("write")

  if vim.bo.filetype == "c" then
    CC = "gcc"
  end
  if vim.bo.filetype == "cpp" then
    CC = "g++"
  end
  -- 4. Set 'makeprg' to our gcc command and run :make
  --    string.format inserts our filenames safely into the command string
  vim.opt.makeprg = string.format(
    "%s -Wall %s -o %s",
    CC,
    vim.fn.shellescape(filename_full_path), -- Use full path for compiler
    vim.fn.shellescape(output_name) -- Use local path for output
  )
  vim.cmd("make")

  -- 5. Check if Quickfix list has entries (meaning compilation failed/warned)
  if #vim.fn.getqflist() > 0 then
    -- COMPILATION FAILED: Open Quickfix list and stop
    vim.cmd("copen")
    print("Compilation failed! Errors in Quickfix list. Terminal aborted.")
    return -- Stop here
  end

  -- COMPILATION SUCCEEDED: Open ToggleTerm and run the file.

  -- 6. Check if toggleterm.terminal module is available
  local status_ok, terminal_module = pcall(require, "toggleterm.terminal")
  if not status_ok or not terminal_module then
    print("toggleterm.nvim not found or 'toggleterm.terminal' module failed to load. Please install it.")
    return
  end

  -- 7. Get the Terminal object from the correct module
  local Term = terminal_module.Terminal
  if not Term then
    print("Error: Could not find 'Terminal' object in 'toggleterm.terminal' module. Is toggleterm installed correctly?")
    return
  end

  local term_to_run = Term:new({
    cmd = output_name, -- Run the compiled file (e.g., ./file.out)
    direction = "horizontal", -- Open at the bottom
    on_open = function(t)
      -- Map <Esc> INSIDE this specific terminal to close it and delete the buffer
      vim.keymap.set("t", "<Esc>", "<Cmd>close<CR><Cmd>bdelete! " .. t.bufnr .. "<CR>", {
        buffer = t.bufnr,
        silent = true,
        -- desc = "Close ToggleTerm",
      })
    end,
    auto_scroll = true, -- Keep scrolled to the bottom
  })

  -- 8. Open the terminal
  term_to_run:open()

  -- =====================================================================
  -- END: Replacement block
  -- =====================================================================
end, {
  silent = false,
  desc = "C: Compile and Interactive run (ToggleTerm)",
})
