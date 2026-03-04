return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "prettierd" },
      typescript = { "prettierd" },
      python = { "black" }, -- Add more here
    }, -- Set a timeout for formatting
    format_timeout_ms = 6000,
  },
}
