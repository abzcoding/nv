return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      dim_inactive = true,
      terminal_colors = false,
      on_highlights = function(highlights, colors)
        highlights.FoldColumn.bg = colors.none
        highlights.SignColumn.bg = colors.none
      end,
    },
  },
}
