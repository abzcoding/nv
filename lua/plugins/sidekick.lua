local is_online = require("config.utils").is_online()

return {
  "folke/sidekick.nvim",
  cmd = "Sidekick",
  dependencies = {
    "zbirenbaum/copilot.lua",
  },
  opts = {
    cli = {
      mux = {
        backend = "tmux",
        enabled = true,
      },
    },
    nes = { enabled = is_online },
    copilot = {
      status = {
        enabled = is_online,
      },
    },
  },
  keys = {
    {
      "<tab>",
      function()
        if not require("sidekick").nes_jump_or_apply() then
          return "<Tab>"
        end
      end,
      expr = true,
      desc = "Goto/Apply Next Edit Suggestion",
    },
    {
      "<leader>as",
      function()
        require("sidekick.cli").toggle()
      end,
      desc = "Sidekick Toggle CLI",
    },
  },
}
