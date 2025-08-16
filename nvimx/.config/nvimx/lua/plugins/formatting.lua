return {
  -- Core: none-ls
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null = require("null-ls")

      null.setup({
        -- don't hardcode sources here; mason-null-ls will handle it
        debounce = 150,
      })

      -- Format-on-save (optional)
      local grp = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = grp,
        callback = function(args)
          vim.lsp.buf.format({
            bufnr = args.buf,
            timeout_ms = 2000,
            filter = function(client) return client.name == "null-ls" end,
          })
        end,
      })
    end,
  },

  -- Bridge: mason <-> none-ls
  {
    "jay-babu/mason-null-ls.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "nvimtools/none-ls.nvim",
    },
    opts = {
      ensure_installed = {
        "stylua",
        "clang-format",
        "shfmt",
        "black",
        "isort",
        "prettierd",
      },
      automatic_installation = true,
      handlers = {},
    },
  },
}
