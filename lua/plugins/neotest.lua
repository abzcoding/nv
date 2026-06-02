return {
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/nvim-nio", "mrcjkb/rustaceanvim", "alfaix/neotest-gtest" },
    lazy = true,
    config = function()
      local opts = {
        adapters = {
          require("rustaceanvim.neotest"),
          require("neotest-gtest").setup({
            root = function(file)
              return require("neotest.lib").files.match_root_pattern("CMakeLists.txt", "compile_commands.json", ".git")(
                file
              )
            end,
            is_test_file = function(file)
              return file:match("test.*%.cpp$") or file:match(".*_test%.cpp$")
            end,
            filter_dir = function(name, rel_path, root)
              return name ~= "build" and name ~= ".git" and name ~= ".cache" and name ~= "_deps"
            end,
            debug_adapter = "codelldb", -- or "cppdbg"
          }),
        },
        quickfix = {
          enabled = false,
        },
        status = { virtual_text = true },
        output = {
          enabled = true,
          open_on_run = true,
        },
        output_panel = {
          enabled = true,
          open = "botright split | resize 15",
        },
        consumers = {
          overseer = require("neotest.consumers.overseer"),
        },
      }
      require("neotest").setup(opts)
    end,
    -- stylua: ignore
    keys = {
      {"<leader>t", "", desc = "+test"},
      { "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File (Neotest)" },
      { "<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run All Test Files (Neotest)" },
      { "<leader>tr", function() require("neotest").run.run() end, desc = "Run Nearest (Neotest)" },
      { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run Last (Neotest)" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary (Neotest)" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output (Neotest)" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel (Neotest)" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop (Neotest)" },
      { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Toggle Watch (Neotest)" },
    },
  },
}
