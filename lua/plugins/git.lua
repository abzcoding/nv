local get_main_branch = function()
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  local result = vim
    .system({ "git", "symbolic-ref", "--short", "refs/remotes/origin/HEAD" }, {
      text = true,
      cwd = (dir ~= "" and vim.uv.fs_stat(dir)) and dir or nil,
    })
    :wait()
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
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "" },
        change = { text = "" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "" },
        untracked = { text = "" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "┃" },
        changedelete = { text = "┃" },
      },
    },
  },
  {
    "nvim-mini/mini.diff",
    event = "VeryLazy",
    opts = {
      view = {
        style = "sign",
        signs = { add = "▎", change = "▎", delete = "" },
      },
      mappings = {
        apply = "",
        reset = "",
        textobject = "",
        goto_first = "",
        goto_prev = "",
        goto_next = "",
        goto_last = "",
      },
    },
  },
}
