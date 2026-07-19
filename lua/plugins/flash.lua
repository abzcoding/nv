return {
  "folke/flash.nvim",
  -- TODO: Remove when https://github.com/folke/flash.nvim/pull/492 is merged.
  commit = "70da6362c68772a6d2e316b691b701bf6b53936f",
  opts = function(_, opts)
    opts = opts or {}
    opts.modes = {
      char = {
        enabled = true,
        keys = { "f", "F", "t", "T", "," },
        char_actions = function(motion)
          return {
            [","] = "prev",
            [motion:lower()] = "next",
            [motion:upper()] = "prev",
          }
        end,
      },
    }
  end,
}
