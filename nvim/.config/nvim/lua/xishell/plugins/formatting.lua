---@module "lazy"
---@type LazySpec
return {
  { "nvim-lua/plenary.nvim", lazy = false, priority = 1000 },
  { "williamboman/mason.nvim", opts = {} },

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
      return {
        -- Run formatting on save (falls back to LSP if none configured)
        format_on_save = function(bufnr)
          -- Disable for very large files
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
          if ok and stats and stats.size > 1024 * 1024 then
            return nil
          end
          return { timeout_ms = 2000, lsp_fallback = true }
        end,

        -- Pick formatters per filetype (first that exists on PATH wins)
        formatters_by_ft = {
          lua = { "stylua" },

          -- JS/TS & web
          javascript = { "prettierd", "prettier" },
          typescript = { "prettierd", "prettier" },
          javascriptreact = { "prettierd", "prettier" },
          typescriptreact = { "prettierd", "prettier" },
          vue = { "prettierd", "prettier" },
          svelte = { "prettierd", "prettier" },
          css = { "prettierd", "prettier" },
          scss = { "prettierd", "prettier" },
          less = { "prettierd", "prettier" },
          html = { "prettierd", "prettier" },
          json = { "prettierd", "prettier" },
          jsonc = { "prettierd", "prettier" },
          yaml = { "prettierd", "prettier" },
          markdown = { "prettierd", "prettier" },
          ["markdown.mdx"] = { "prettierd", "prettier" },

          -- Shell
          sh = { "shfmt" },
          bash = { "shfmt" },
          zsh = { "shfmt" },

          -- Python
          python = { "isort", "black" }, -- order matters: isort then black

          -- C/C++
          c = { "clang-format" },
          cpp = { "clang-format" },

          -- Java
          java = { "google-java-format" },

          -- Go / Rust (use LSP fallback if tool missing)
          go = { "gofumpt", "goimports-reviser" },
          rust = { "rustfmt" },

          -- Misc
          toml = { "taplo" },
          sql = { "sql-formatter" },
        },

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

  -- Mason tool installer for formatters and linters
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        -- formatters
        "stylua",
        "prettierd",
        "shfmt",
        "black",
        "isort",
        "clang-format",
        "google-java-format",
        "gofumpt",
        "goimports-reviser",
        "rustfmt",
        "taplo",
        "sql-formatter",

        -- diagnostics/linters (for future use)
        "eslint_d",
        "ruff",
        "shellcheck",
        "markdownlint",
        "yamllint",
        "jsonlint",
        "golangci-lint",
      },
      auto_update = false,
      run_on_start = true,
    },
  },
}
