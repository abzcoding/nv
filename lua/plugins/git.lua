local get_main_branch = function()
  local result = vim.system({ "git", "symbolic-ref", "--short", "refs/remotes/origin/HEAD" }, { text = true }):wait()
  if result.code ~= 0 then
    return ""
  end

  return vim.trim(result.stdout or ""):match("^origin/(.+)$") or ""
end

return {
  {
    "dlyongemallo/diffview-plus.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
    keys = {
      { "<leader>gdd", "<cmd>DiffviewOpen<CR>", desc = "DiffView" },
      { "<leader>gD", "<cmd>DiffviewFileHistory %<CR>", desc = "History" },
      {
        "<leader>gdm",
        function()
          local branch = get_main_branch()
          if branch == "" then
            vim.notify("Could not determine origin's main branch", vim.log.levels.WARN)
            return
          end
          vim.api.nvim_cmd({ cmd = "DiffviewOpen", args = { branch } }, {})
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
