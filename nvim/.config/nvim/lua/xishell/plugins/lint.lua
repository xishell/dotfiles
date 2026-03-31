---@module "lazy"
---@type LazySpec
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      python = { "ruff" },
      sh = { "shellcheck" },
      bash = { "shellcheck" },
      go = { "golangcilint" },
      markdown = { "markdownlint" },
      yaml = { "yamllint" },
      json = { "jsonlint" },
    }

    -- Lint on save, insert leave, and after reading a file
    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "BufReadPost" }, {
      group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
      callback = function()
        -- Only lint if the buffer has a file on disk
        if vim.bo.buftype == "" then
          lint.try_lint()
        end
      end,
    })
  end,
}
