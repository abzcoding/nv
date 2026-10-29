return {
  "catppuccin",
  optional = true,
  opts = {
    flavour = "mocha",
    background = { light = "latte", dark = "mocha" },
    integrations = {
      avante = {
        windows_sidebar_header_rounded = true,
      },
      blink_cmp = true,
      dap = {
        enabled = true,
        enable_ui = true,
      },
      gitsigns = true,
      lsp_trouble = true,
      mason = true,
      neotest = true,
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = { "italic" },
          hints = {},
          warnings = { "italic" },
          information = {},
        },
        underlines = {
          errors = { "undercurl" },
          hints = {},
          warnings = { "undercurl" },
          information = {},
        },
      },
      overseer = true,
      telescope = true,
      treesitter = true,
    },
    term_colors = false,
    styles = {
      comments = {},
      keywords = { "italic" },
    },
    compile = {
      enabled = true,
      path = vim.fn.stdpath("cache") .. "/catppuccin",
    },
    dim_inactive = {
      enabled = true,
      shade = "dark",
      percentage = 0.15,
    },
    custom_highlights = function(c)
      local bg_alt = "#242438"
      local bg = "#161621"
      local highlights = {
        BlinkCmpDoc = { fg = c.text, bg = bg },
        BlinkCmpDocBorder = { fg = bg, bg = bg },
        BlinkCmpKind = { fg = c.blue },
        BlinkCmpMenu = { fg = c.text, bg = bg },
        BlinkCmpMenuBorder = { fg = bg, bg = bg },
        BlinkCmpMenuSelection = { bg = bg_alt, bold = true },
        BlinkCmpScrollBarGutter = { bg = bg },
        BlinkCmpSignatureHelp = { fg = c.text, bg = bg },
        BlinkCmpSignatureHelpActiveParameter = { fg = c.mauve },
        BlinkCmpSignatureHelpBorder = { fg = bg, bg = bg },
        ColorColumn = { bg = c.mantle },
        Cursor = { fg = c.base, bg = "#d9e0ee" },
        Folded = { fg = c.lavender, bg = c.dim },
        MarkviewPalette1Fg = { fg = "#d9e0ee" },
        MarkviewCode = { bg = c.mantle },
        MarkviewCodeFg = { fg = c.mantle },
        MarkviewCodeInfo = { fg = c.overlay2, bg = c.mantle },
        TSConstBuiltin = { fg = c.maroon },
        TelescopeBorder = { fg = bg_alt, bg = bg },
        TelescopeNormal = { bg = bg },
        TelescopePreviewBorder = { fg = bg, bg = bg },
        TelescopePreviewNormal = { bg = bg },
        TelescopePreviewTitle = { fg = bg, bg = c.green },
        TelescopePromptBorder = { fg = bg_alt, bg = bg_alt },
        TelescopePromptNormal = { fg = c.text, bg = bg_alt },
        TelescopePromptPrefix = { fg = c.red, bg = bg_alt },
        TelescopePromptTitle = { fg = bg, bg = c.red },
        TelescopeResultsBorder = { fg = bg, bg = bg },
        TelescopeResultsNormal = { bg = bg },
        TelescopeResultsTitle = { fg = bg, bg = bg },
        TelescopeSelection = { bg = bg_alt },
        TermCursor = { fg = "#000000", bg = "#B7BDF8" },
        TreesitterContextLineNumber = { fg = "#494D64", bg = "#1e2030" },
        Unvisited = { bg = "#34344F" },
        ["@constant.builtin"] = { fg = c.maroon },
        rainbow1 = { fg = c.red, bg = "#302D41" },
        rainbow2 = { fg = c.peach, bg = "#302D41" },
        rainbow3 = { fg = c.yellow, bg = "#302D41" },
        rainbow4 = { fg = c.green, bg = "#302D41" },
        rainbow5 = { fg = c.sapphire, bg = "#302D41" },
        rainbow6 = { fg = c.lavender, bg = "#302D41" },
      }
      local blend = require("catppuccin.utils.colors").blend
      local diagnostics = {
        Error = c.red,
        Warn = blend(c.peach, c.yellow, 0.6),
        Info = c.blue,
        Hint = blend(c.teal, c.overlay1, 0.6),
      }
      for severity, color in pairs(diagnostics) do
        for _, prefix in ipairs({ "Diagnostic", "DiagnosticSign", "DiagnosticFloating" }) do
          highlights[prefix .. severity] = { fg = color }
        end
        highlights["DiagnosticVirtualText" .. severity] = { fg = color, bg = blend(color, c.base, 0.095) }
        highlights["DiagnosticUnderline" .. severity] = { sp = color }
      end
      return highlights
    end,
  },
}
