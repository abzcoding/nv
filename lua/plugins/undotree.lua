return {
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>uT", "<cmd>UndotreeToggle<cr>", desc = "Undo Tree Toggle", noremap = true },
    },
    init = function()
      -- Persist undo, refer https://github.com/mbbill/undotree#usage
      local undodir = vim.fn.expand("~/.undo-nvim")

      if vim.fn.has("persistent_undo") == 1 then
        if vim.fn.isdirectory(undodir) == 0 then
          vim.notify("please create ~/.undo-nvim", vim.log.levels.WARN)
        end

        vim.opt.undodir = undodir
        vim.opt.undofile = true
      end

      -- set layout style to 2, let g:undotree_WindowLayout = 2
      vim.g.undotree_WindowLayout = 2
    end,
  },
}
