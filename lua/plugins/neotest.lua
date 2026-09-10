return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "mrcjkb/rustaceanvim",
      "abzcoding/neotest-gtest",
    },
    lazy = true,
    opts = {
      adapters = {
        ["rustaceanvim.neotest"] = {},
        ["neotest-gtest"] = {
          root = function(file)
            return require("neotest.lib").files.match_root_pattern("CMakePresets.json", "compile_commands.json", ".git")(
              file
            )
          end,
          is_test_file = function(file)
            local name = vim.fs.basename(file)
            return name:match("^test_.*%.[cC][pP][pP]$") ~= nil or name:match(".*_test%.[cC][pP][pP]$") ~= nil
          end,
          filter_dir = function(name)
            return name ~= "build" and name ~= ".git" and name ~= ".cache" and name ~= "_deps"
          end,
          debug_adapter = "codelldb",
        },
      },
      quickfix = {
        enabled = false,
      },
      status = { virtual_text = true },
      output = {
        enabled = true,
        open_on_run = false,
      },
      output_panel = {
        enabled = false,
      },
    },
    -- stylua: ignore
    keys = {
      {"<leader>t", "", desc = "+test"},
      { "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%:p")) end, desc = "Run File (Neotest)" },
      { "<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run All Test Files (Neotest)" },
      { "<leader>tr", function() require("neotest").run.run() end, desc = "Run Nearest (Neotest)" },
      { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run Last (Neotest)" },
      { "<leader>ts", function()
          local summary_open = false
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "neotest-summary" then
              summary_open = true
              break
            end
          end

          if summary_open then
            require("neotest").summary.close()
          else
            require("overseer").close()
            require("neotest").summary.open()
          end
        end, desc = "Toggle Summary (Neotest)" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output (Neotest)" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop (Neotest)" },
      { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%:p")) end, desc = "Toggle Watch (Neotest)" },
    },
  },
}
