-- Defines the function to compile and launch the interactive terminal
vim.keymap.set("n", "<leader>t", function()
  -- 1. Compile the C file (non-interactive shell command)
  -- Uses 'gcc' instead of 'g++', but keeps the -Wall warning flag.
  vim.cmd("!gcc -Wall %")

  -- 2. Check the exit status of the compilation command
  if vim.v.shell_error == 0 then
    -- 3. If compilation succeeded, open a vertical split terminal
    -- This allows the user to manually run './a.out' and interact with it.
    vim.cmd("vsplit term://zsh")
  else
    -- Optional: Give a visual cue if compilation failed (exit code is non-zero)
    print("Compilation failed. Check errors above.")
  end
end, {
  buffer = true,
  silent = false,
  desc = "Compile C File and Open Interactive Terminal",
})

-- Optional, but highly recommended: Keymap to easily exit Terminal Mode
-- This lets you press <Esc> to switch from Terminal Mode back to Normal Mode.
vim.keymap.set("t", "<Esc>", "<C-\\><C-N>", {
  desc = "Exit terminal mode",
  buffer = true,
})
