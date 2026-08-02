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

      if vim.fn.isdirectory(undodir) == 0 then
        vim.fs.mkdir(undodir, { mode = tonumber("700", 8) })
      end
      vim.opt.undodir = undodir
      -- set layout style to 2, let g:undotree_WindowLayout = 2
      vim.g.undotree_WindowLayout = 2
    end,
  },
}
