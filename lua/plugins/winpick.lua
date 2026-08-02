return {
  "s1n7ax/nvim-window-picker",
  name = "window-picker",
  -- event = "VeryLazy",
  version = "2.*",
  config = function()
    require("window-picker").setup({
      hint = "floating-big-letter",
      show_prompt = false,
    })
  end,
  keys = {
    {
      ";w",
      function()
        local picked_window_id = require("window-picker").pick_window() or vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_win(picked_window_id)
      end,
      mode = "n",
      desc = "Pick a window",
    },
    {
      ";s",
      function()
        local window = require("window-picker").pick_window()
        if not window or not vim.api.nvim_win_is_valid(window) then
          return
        end
        local current = vim.api.nvim_get_current_win()
        if window == current then
          return
        end
        local current_buffer = vim.api.nvim_win_get_buf(current)
        local target_buffer = vim.api.nvim_win_get_buf(window)
        vim.api.nvim_win_set_buf(window, current_buffer)
        vim.api.nvim_win_set_buf(current, target_buffer)
      end,
      mode = "n",
      desc = "Swap window",
    },
  },
}
