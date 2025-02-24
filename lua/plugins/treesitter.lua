return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    highlight = { enable = true },
    ensure_installed = {
      "bash",
      "c",
      "cpp",
      "css",
      "diff",
      "dockerfile",
      "git_rebase",
      "gitattributes",
      "gitcommit",
      "gitignore",
      "go",
      "gomod",
      "gosum",
      "gowork",
      "html",
      "htmldjango",
      "http",
      "ini",
      "javascript",
      "jsdoc",
      "json",
      "jsonc",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "printf",
      "python",
      "query",
      "regex",
      "rust",
      "sql",
      "terraform",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "xml",
      "yaml",
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-n>",
        node_incremental = "<C-n>",
        scope_incremental = "<C-r>",
        node_decremental = "<bs>",
      },
    },
    -- textobjects = {
    --   move = {
    --     enable = true,
    --     goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
    --     goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
    --     goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
    --     goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
    --   },
    --   select = {
    --     enable = true,
    --     lookahead = true,
    --     keymaps = {
    --       ["aA"] = "@attribute.outer",
    --       ["iA"] = "@attribute.inner",
    --       ["ab"] = "@block.outer",
    --       ["ib"] = "@block.inner",
    --       ["ac"] = "@call.outer",
    --       ["ic"] = "@call.inner",
    --       ["at"] = "@class.outer",
    --       ["it"] = "@class.inner",
    --       ["a/"] = "@comment.outer",
    --       ["i/"] = "@comment.inner",
    --       ["ai"] = "@conditional.outer",
    --       ["ii"] = "@conditional.inner",
    --       ["aF"] = "@frame.outer",
    --       ["iF"] = "@frame.inner",
    --       ["af"] = "@function.outer",
    --       ["if"] = "@function.inner",
    --       ["al"] = "@loop.outer",
    --       ["il"] = "@loop.inner",
    --       ["aa"] = "@parameter.outer",
    --       ["ia"] = "@parameter.inner",
    --       ["is"] = "@scopename.inner",
    --       ["as"] = "@statement.outer",
    --       ["av"] = "@variable.outer",
    --       ["iv"] = "@variable.inner",
    --     },
    --   },
    -- },
  },
}
