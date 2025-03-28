local aucmd = vim.api.nvim_create_autocmd

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
aucmd({ "InsertEnter" }, {
  callback = function()
    local fname = vim.fn.bufname()
    if fname == "copilot-chat" or vim.bo.buftype == "nofile" then
      return
    end
    vim.opt_local.relativenumber = false
  end,
})

-- and absolute line numbers in insert mode
aucmd({ "InsertLeave" }, {
  callback = function()
    local fname = vim.fn.bufname()
    if fname == "copilot-chat" or vim.bo.buftype == "nofile" then
      return
    end
    vim.opt_local.relativenumber = true
  end,
})

-- Terminal
aucmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
  end,
})

-- Codelens
aucmd({ "BufEnter", "InsertLeave" }, {
  pattern = { "*.rs", "*.go" },
  callback = function()
    vim.lsp.codelens.refresh({ bufnr = 0 })
  end,
})

aucmd("TermOpen", {
  pattern = "term://*",
  callback = function()
    require("config.utils").set_terminal_keymaps()
  end,
})

vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- aucmd("WinEnter", {
--   callback = function()
--     vim.opt_local.number = true
--     vim.opt_local.relativenumber = true
--     vim.opt_local.cursorline = true
--   end,
-- })
-- aucmd("WinLeave", {
--   callback = function()
--     vim.opt_local.number = false
--     vim.opt_local.relativenumber = false
--     vim.opt_local.cursorline = false
--   end,
-- })

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
