--return {
--  "stevearc/oil.nvim",
--  ---@module 'oil'
--  ---@type oil.SetupOpts
--  opts = {},
--  -- Optional dependencies
--  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
--  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
--  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
--  lazy = false,
--}
--
return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    -- This opens Oil in a floating window (the "terminal" feel)
    { "<leader>o", "<cmd>lua require('oil').open_float()<cr>", desc = "Open Oil (Float)" },
  },
  opts = {
    -- 1. Make it the default explorer
    default_file_explorer = true,

    -- 2. Clean up the columns (just icons and names)
    columns = { "icon" },

    -- 3. macOS friendly trash
    delete_to_trash = true,

    -- 4. Show hidden files by default
    view_options = {
      show_hidden = true,
    },

    -- 5. THE FLOATING WINDOW SETUP
    float = {
      padding = 2,
      max_width = 0.8, -- 80% of screen width
      max_height = 0.8, -- 80% of screen height
      border = "rounded", -- Makes it look like a modern terminal popup
      win_options = {
        winblend = 0, -- Set to 10-20 if you want a transparent feel
      },
    },

    -- 6. Essential Keymaps inside the Oil buffer
    keymaps = {
      ["<C-c>"] = "actions.close",
      ["<CR>"] = "actions.select",
      ["<C-p>"] = "actions.preview",
      ["-"] = "actions.parent",
    },
  },
}
