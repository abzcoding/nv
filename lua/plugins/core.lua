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
        local rb_bg = "#2f334d"
        highlights.rainbow1 = { fg = colors.red, bg = rb_bg }
        highlights.rainbow2 = { fg = colors.orange, bg = rb_bg }
        highlights.rainbow3 = { fg = colors.yellow, bg = rb_bg }
        highlights.rainbow4 = { fg = colors.green, bg = rb_bg }
        highlights.rainbow5 = { fg = colors.blue, bg = rb_bg }
        highlights.rainbow6 = { fg = colors.purple, bg = rb_bg }
      end,
    },
  },
}
