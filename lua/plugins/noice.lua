return {
  "folke/noice.nvim",
  opts = {
    lsp = {
      signature = { enabled = false }, -- Blink owns automatic signature help.
    },
    presets = {
      lsp_doc_border = false,
    },
    cmdline = {
      view = "cmdline",
    },
    routes = {
      {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      },
      {
        filter = {
          event = "notify",
          find = "Toggling hidden files",
        },
        opts = { skip = true },
      },
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
          },
        },
        view = "mini",
      },
    },
  },
}
