return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
      icons = require("config.icons"),
    },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      dim_inactive = true,
      terminal_colors = false,
      on_colors = function(colors)
        colors.error = colors.red1
        colors.warning = colors.orange
        colors.info = colors.blue
        colors.hint = require("tokyonight.util").blend(colors.cyan, 0.6, colors.comment)
      end,
      on_highlights = function(highlights, colors)
        highlights.FoldColumn.bg = colors.none
        highlights.SignColumn.bg = colors.none
        for _, group in ipairs({ "BlinkCmpMenu", "BlinkCmpDoc", "BlinkCmpSignatureHelp" }) do
          highlights[group] = { fg = colors.fg, bg = colors.bg_float }
          highlights[group .. "Border"] = { fg = colors.bg_float, bg = colors.bg_float }
        end
        highlights.BlinkCmpMenuSelection = { bg = colors.bg_highlight, bold = true }
        highlights.BlinkCmpScrollBarGutter = { bg = colors.bg_float }
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
