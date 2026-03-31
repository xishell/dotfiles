---@module "lazy"
---@type LazySpec
return {
  { "nvim-lua/plenary.nvim", lazy = false, priority = 1000 },

  -- Format-on-save engine
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = function()
      local cfg = require("xishell.config")
      local disabled_ft = cfg.get("format_disabled_ft") or {}

      -- Prettier-based filetypes (DRY)
      local prettier = { "prettierd", "prettier", stop_after_first = true }
      local prettier_fts = {
        "javascript", "typescript", "javascriptreact", "typescriptreact",
        "vue", "svelte", "css", "scss", "less", "html",
        "json", "jsonc", "yaml", "markdown", "markdown.mdx",
      }

      local formatters_by_ft = {
        lua = { "stylua" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        python = { "isort", "black" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        java = { "google-java-format" },
        go = { "gofumpt", "goimports-reviser" },
        rust = { "rustfmt" },
        toml = { "taplo" },
        sql = { "sql-formatter" },
      }

      -- Add prettier filetypes
      for _, ft in ipairs(prettier_fts) do
        formatters_by_ft[ft] = prettier
      end

      return {
        -- Run formatting on save (falls back to LSP if none configured)
        format_on_save = function(bufnr)
          local ft = vim.bo[bufnr].filetype
          -- Skip disabled filetypes from config
          if vim.tbl_contains(disabled_ft, ft) then
            return nil
          end
          -- Disable for very large files
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
          if ok and stats and stats.size > 1024 * 1024 then
            return nil
          end
          return { timeout_ms = 2000, lsp_fallback = true }
        end,

        formatters_by_ft = formatters_by_ft,

        -- Per-formatter args (optional)
        formatters = {
          shfmt = { prepend_args = { "-i", "2", "-ci" } },
          stylua = { prepend_args = { "--search-parent-directories" } },
          ["clang-format"] = {
            prepend_args = { "--style={IndentWidth: 4, TabWidth: 4, UseTab: Never}" },
          },
          ["google-java-format"] = {
            -- example: set style (leave empty to use default)
            -- prepend_args = { "--aosp" },
          },
        },
      }
    end,
  },
}
