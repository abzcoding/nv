local function generic_hl(group)
  return {
    ["github%.com/[%a%d%-%_%.]+%/?$"] = {
      hl = group,
    },
    ["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/?$"] = {
      hl = group,
    },
    ["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/tree/[%a%d%-%_%.]+%/?$"] = {
      hl = group,
    },
    ["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/commits/[%a%d%-%_%.]+%/?$"] = {
      hl = group,
    },
    ["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/releases$"] = {
      hl = group,
    },
    ["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/tags$"] = {
      hl = group,
    },
    ["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/issues$"] = {
      hl = group,
    },
    ["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/pulls$"] = {
      hl = group,
    },
    ["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/wiki$"] = {
      hl = group,
    },
  }
end

return {
  "OXY2DEV/markview.nvim",
  ft = { "markdown", "Avante" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local presets = require("markview.presets")

    require("markview").setup({
      markdown_inline = {
        enable = true,
        checkboxes = presets.checkboxes.nerd,
        hyperlinks = generic_hl("MarkviewHyperlink"),
        uri_autolinks = generic_hl("MarkviewEmail"),
      },
      markdown = {
        enable = true,
        headings = presets.headings.glow,
        tables = presets.tables.rounded,
        code_blocks = { sign = false, min_width = 80 },
        reference_definitions = generic_hl("MarkviewPalette4Fg"),
      },
      typst = {
        url_links = generic_hl("MarkviewEmail"),
      },
    })
  end,
}
