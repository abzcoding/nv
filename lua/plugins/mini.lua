return {
  {
    "nvim-mini/mini.splitjoin",
    version = "*",
    keys = {
      {
        "gS",
        function()
          require("mini.splitjoin").toggle()
        end,
        desc = "Toggle Split/Join",
      },
    },
    opts = {},
  },
  {
    "nvim-mini/mini.surround",
    keys = {
      { "gsa", mode = { "n", "v" }, desc = "Add Surrounding" },
      { "gsd", desc = "Delete Surrounding" },
      { "gsf", desc = "Find Right Surrounding" },
      { "gsF", desc = "Find Left Surrounding" },
      { "gsh", desc = "Highlight Surrounding" },
      { "gsr", desc = "Replace Surrounding" },
      { "gsn", desc = "Update `n_lines`" },
    },
    opts = {
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
      },
    },
  },
}
