return {
  "stevearc/overseer.nvim",

  opts = {
    strategy = "jobstart",

    output = {
      preserve_output = false,
    },

    task_list = {
      direction = "right",
      keymaps = {
        ["dd"] = {
          "keymap.run_action",
          opts = { action = "dispose" },
        },
      },
    },

    component_aliases = {
      default = {
        "right_dock",
        "on_exit_set_status",
        "on_complete_notify",
        {
          "on_complete_dispose",
          require_view = { "SUCCESS", "FAILURE" },
        },
      },
    },
  },
}
