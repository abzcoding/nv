local active_task_id
local output_win

local function valid(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function open_layout(task)
  active_task_id = task.id

  local overseer = require("overseer")
  local original_win = vim.api.nvim_get_current_win()
  local list_win = require("overseer.window").get_win_id()

  if not valid(output_win) then
    if valid(list_win) then
      vim.api.nvim_set_current_win(list_win)
      vim.cmd("aboveleft split")
      output_win = vim.api.nvim_get_current_win()
    else
      vim.api.nvim_set_current_win(original_win)
      vim.cmd("botright vsplit")
      output_win = vim.api.nvim_get_current_win()

      vim.cmd("belowright split")
      list_win = vim.api.nvim_get_current_win()

      overseer.open({
        winid = list_win,
        direction = "right",
        enter = false,
      })
    end

    overseer.create_task_output_view(output_win, {
      close_on_list_close = true,
      select = function(_, tasks)
        for _, candidate in ipairs(tasks) do
          if candidate.id == active_task_id then
            return candidate
          end
        end
      end,
    })
  end

  local right_width = math.max(1, math.floor(vim.o.columns * 0.40))

  vim.api.nvim_win_resize(output_win, right_width, -1, {
    anchor = "right",
  })

  vim.wo[output_win].winfixwidth = true

  if valid(list_win) then
    vim.api.nvim_win_resize(list_win, -1, 13, {
      anchor = "bottom",
    })

    vim.wo[list_win].winfixwidth = true
    vim.wo[list_win].winfixheight = true
  end

  overseer.open({
    enter = false,
    focus_task_id = task.id,
  })

  vim.api.nvim_exec_autocmds("User", {
    pattern = "OverseerListUpdate",
    modeline = false,
  })

  if valid(original_win) then
    vim.api.nvim_set_current_win(original_win)
  end
end

return {
  desc = "Shared output above right-side task list",
  editable = false,
  serializable = false,

  constructor = function()
    return {
      on_start = function(_, task)
        vim.schedule(function()
          if not task:is_disposed() then
            open_layout(task)
          end
        end)
      end,
    }
  end,
}
