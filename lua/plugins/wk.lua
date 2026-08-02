return {
  "folke/which-key.nvim",
  opts = {
    spec = {
      { "<leader>a", group = "AI", icon = " " },
      { "<leader>1", hidden = true },
      { "<leader>2", hidden = true },
      { "<leader>3", hidden = true },
      { "<leader>4", hidden = true },
      { "<leader>5", hidden = true },
      { "<leader>6", hidden = true },
    },
    icons = {
      rules = {
        { pattern = "readability", icon = "󰊰 ", color = "blue" },
        { pattern = "optimize", icon = " ", color = "green" },
        { pattern = "summarize", icon = " ", color = "cyan" },
        { pattern = "explain", icon = "󰘦 ", color = "orange" },
        { pattern = "fix", icon = "  ", color = "red" },
        { pattern = "tests", icon = " ", color = "azure" },
        { pattern = "ask", icon = "󱜺 ", color = "green" },
        { pattern = "refresh", icon = " ", color = "yellow" },
        { pattern = "focus", icon = "󰋱 ", color = "purple" },
        { pattern = "model", icon = " ", color = "grey" },
        { pattern = "repo", icon = " ", color = "cyan" },
        { pattern = "overseer", icon = "󰑮 ", color = "cyan" },
      },
    },
  },
}
