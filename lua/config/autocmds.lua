vim.api.nvim_create_user_command("OverseerRestartLast", function()
  local overseer = require("overseer")
  local tasks = overseer.list_tasks({ recent_first = true })
  if vim.tbl_isempty(tasks) then
    vim.notify("No tasks found", vim.log.levels.WARN)
  else
    overseer.run_action(tasks[1], "restart")
  end
end, {})

-- Set relative line numbers in normal mode
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  pattern = "*",
  callback = function()
    if vim.fn.bufname() ~= "copilot-chat" then
      vim.opt.relativenumber = false
    end
  end,
})

-- and absolute line numbers in insert mode
vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  pattern = "*",
  callback = function()
    if vim.fn.bufname() ~= "copilot-chat" then
      vim.opt.relativenumber = true
    end
  end,
})

-- Terminal
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
  end,
})

-- Codelens
vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
  pattern = { "*.rs, *.go" },
  callback = function()
    vim.lsp.codelens.refresh({ bufnr = 0 })
  end,
})

-- -- blink.cmp hide copilot suggestion
-- vim.api.nvim_create_autocmd('User', {
--   pattern = 'BlinkCmpMenuOpen',
--   callback = function()
--     require("copilot.suggestion").dismiss()
--     vim.b.copilot_suggestion_hidden = true
--   end,
-- })
--
-- vim.api.nvim_create_autocmd('User', {
--   pattern = 'BlinkCmpMenuClose',
--   callback = function()
--     vim.b.copilot_suggestion_hidden = false
--   end,
-- })
