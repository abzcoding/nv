return {
  "mfussenegger/nvim-lint",
  event = "BufWritePost",
  init = function()
    vim.api.nvim_create_user_command("Lint", function()
      require("lint").try_lint()
    end, { desc = "Lint the current buffer" })

    vim.api.nvim_create_user_command("LintTerraform", function()
      if not vim.tbl_contains({ "terraform", "tf" }, vim.bo.filetype) then
        vim.notify("LintTerraform requires a Terraform buffer", vim.log.levels.WARN)
        return
      end
      require("lint").try_lint({ "terraform_validate", "tflint" })
    end, { desc = "Run Terraform validation and tflint" })

    vim.api.nvim_create_user_command("LintTrivy", function()
      require("lint").try_lint("trivy")
    end, { desc = "Run Trivy for the current buffer" })
  end,
  opts = {
    events = { "BufWritePost" },
    linters_by_ft = {
      ["yaml.ansible"] = { "ansible_lint" },
      dockerfile = { "hadolint" },
      fish = { "fish" },
      gha = { "actionlint" },
      sh = { "shellcheck" },
      typescript = { "eslint_d" },
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
