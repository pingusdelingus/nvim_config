return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

      parser_config.prolog = {

        install_info = {
          url = "/Users/esteballs/Documents/coding stuff/tree-sitter-prolog",
          files = { "src/parser.c" },
          generate_requires_npm = false,
          requires_generate_from_grammar = false,
          filetype = "pl",
        },
      }
      parser_config.tptp = {
        install_info = {
          -- ABSOLUTE path to your tree-sitter-tptp source directory
          url = "/Users/esteballs/Documents/coding stuff/tree-sitter-tptp",
          files = { "src/parser.c" },
          -- Add "src/scanner.c" to the list above if your parser has one!
          generate_requires_npm = false,
          requires_generate_from_grammar = false,
        },
        filetype = { "s", "tptp", "p" },
      }

      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "tptp" })
        vim.list_extend(opts.ensure_installed, { "prolog" })
      end
    end,
  },
}
