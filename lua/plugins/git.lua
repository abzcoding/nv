local get_main_branch = function()
  local handle = io.popen("git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null")
  if not handle then
    return ""
  end

  local result = handle:read("*a")
  handle:close()

  if not result or result == "" then
    return ""
  end

  local branch = result:match("refs/remotes/origin/([%w%-_/]+)")
  return branch or ""
end

return {
  {
    "dlyongemallo/diffview-plus.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufReadPre",
    keys = {
      { "<leader>gdd", "<cmd>DiffviewOpen<CR>", desc = "DiffView" },
      { "<leader>gD", "<cmd>DiffviewFileHistory %<CR>", desc = "History" },
      {
        "<leader>gdm",
        function()
          local branch = get_main_branch()
          if branch == "" then
            print("Could not get main branch")
            return
          end
          vim.cmd("DiffviewOpen " .. branch)
        end,
        desc = "DiffView main branch",
      },
    },
    config = function()
      require("diffview").setup({
        default_args = {
          DiffviewFileHistory = { "%" },
        },
        hooks = {
          diff_buf_read = function()
            vim.wo.wrap = false
            vim.wo.list = false
            vim.wo.colorcolumn = ""
          end,
        },
        view = {
          merge_tool = {
            disable_diagnostics = false,
            winbar_info = true,
          },
        },
        keymaps = {
          view = { q = "<Cmd>DiffviewClose<CR>" },
          file_panel = { q = "<Cmd>DiffviewClose<CR>" },
          file_history_panel = { q = "<Cmd>DiffviewClose<CR>" },
        },
      })
    end,
  },
}
