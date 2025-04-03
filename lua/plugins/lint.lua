return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {
      dockerfile = { "hadolint" },
      gha = { "actionlint" },
      sh = { "shellcheck" },
      terraform = { "terraform_validate", "tflint", "trivy" },
      tf = { "terraform_validate", "tflint", "trivy" },
      typescript = { "prettierd" },
      yaml = { "yamllint" },
    },
    linters = {
      yamllint = {
        args = {
          "--config-file",
          vim.fn.expand("~/.yamllint.yml"),
          "--format",
          "parsable",
          "-",
        },
      },
    },
  },
}
