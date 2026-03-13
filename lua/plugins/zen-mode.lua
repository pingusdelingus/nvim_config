--return {
--  "folke/zen-mode.nvim",
--  opts = {
--    window = {
--      backdrop = 1, -- Set to 1 so the background matches your theme exactly
--      width = 1, -- 1 is 100% width (no floating effect)
--      height = 1, -- 1 is 100% height
--      options = {
--        -- This ensures the UI is as clean as possible when full-screen
--        signcolumn = "no",
--        number = false,
--        relativenumber = true,
--      },
--    },
--    plugins = {
--      options = {
--        enabled = true,
--        laststatus = 0, -- Hides the status line at the bottom
--      },
--    },
--  },
--}
-- working
--
return {
  "folke/zen-mode.nvim",
  opts = {
    window = {
      backdrop = 1,
      width = 1, -- 100% width
      height = 1, -- 100% height
      options = {
        signcolumn = "no",
        number = false,
        relativenumber = false,
        cursorline = false,
        foldcolumn = "0", -- Ensures no gap on the left
      },
    },
    plugins = {
      options = {
        enabled = true,
        laststatus = 0,
      },
      -- CRITICAL: Disable tmux integration to prevent it from
      -- trying to "center" the Neovim window inside the tmux pane.
      tmux = { enabled = false },
    },
  },
}
