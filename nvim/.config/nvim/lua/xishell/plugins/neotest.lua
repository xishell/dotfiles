---@module "lazy"
---@type LazySpec
--
-- NOTE: Make sure to install test runners for your languages:
--   Python: pip install pytest pytest-cov
--   Go: Built-in with Go toolchain
--   JavaScript/TypeScript: npm install -D jest / npm install -D vitest
--   Java: Maven/Gradle handles this
--
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-neotest/nvim-nio",
    "nvim-treesitter/nvim-treesitter",

    -- Adapters for different languages
    "nvim-neotest/neotest-python",     -- Python/pytest
    "nvim-neotest/neotest-go",         -- Go
    "nvim-neotest/neotest-jest",       -- JavaScript/TypeScript (Jest)
    "marilari88/neotest-vitest",       -- JavaScript/TypeScript (Vitest)
    "rcasia/neotest-java",             -- Java
  },
  keys = {
    { "<leader>tt", function() require("neotest").run.run() end, desc = "Run Nearest Test" },
    { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run Test File" },
    { "<leader>ta", function() require("neotest").run.run(vim.fn.getcwd()) end, desc = "Run All Tests" },
    { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run Last Test" },
    { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Test Summary" },
    { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Test Output" },
    { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel" },
    { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop Test" },
    { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug Nearest Test" },
    { "<leader>tw", function() require("neotest").watch.toggle() end, desc = "Toggle Watch Mode" },
    { "]t", function() require("neotest").jump.next({ status = "failed" }) end, desc = "Next Failed Test" },
    { "[t", function() require("neotest").jump.prev({ status = "failed" }) end, desc = "Prev Failed Test" },
  },
  config = function()
    local neotest = require("neotest")

    neotest.setup({
      adapters = {
        -- Python
        require("neotest-python")({
          dap = { justMyCode = false },
          runner = "pytest",
          python = function()
            -- Try to find virtual environment python
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
              return cwd .. "/venv/bin/python"
            elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
              return cwd .. "/.venv/bin/python"
            else
              return "python3"
            end
          end,
        }),

        -- Go
        require("neotest-go")({
          args = { "-count=1", "-timeout=60s" }
        }),

        -- Jest (JavaScript/TypeScript)
        require("neotest-jest")({
          jestCommand = "npm test --",
          jestConfigFile = "jest.config.js",
          env = { CI = true },
          cwd = function()
            return vim.fn.getcwd()
          end,
        }),

        -- Vitest (JavaScript/TypeScript)
        require("neotest-vitest"),

        -- Java
        require("neotest-java")({
          ignore_wrapper = false,
        }),
      },

      -- Status display
      status = {
        enabled = true,
        virtual_text = true,
        signs = true,
      },

      -- Icons
      icons = {
        passed = "",
        running = "",
        failed = "",
        skipped = "",
        unknown = "",
        watching = "",
      },

      -- Floating window
      floating = {
        border = "rounded",
        max_height = 0.8,
        max_width = 0.9,
        options = {},
      },

      -- Summary window
      summary = {
        enabled = true,
        expand_errors = true,
        follow = true,
        mappings = {
          attach = "a",
          clear_marked = "M",
          clear_target = "T",
          debug = "d",
          debug_marked = "D",
          expand = { "<CR>", "<2-LeftMouse>" },
          expand_all = "e",
          jumpto = "i",
          mark = "m",
          next_failed = "J",
          output = "o",
          prev_failed = "K",
          run = "r",
          run_marked = "R",
          short = "O",
          stop = "u",
          target = "t",
          watch = "w",
        },
      },

      -- Output window
      output = {
        enabled = true,
        open_on_run = "short",
      },

      -- Output panel
      output_panel = {
        enabled = true,
        open = "botright split | resize 15",
      },

      -- Quickfix
      quickfix = {
        enabled = true,
        open = false,
      },

      -- Diagnostic display
      diagnostic = {
        enabled = true,
        severity = vim.diagnostic.severity.ERROR,
      },

      -- Running indicator
      running = {
        concurrent = true,
      },

      -- State persistence
      state = {
        enabled = true,
      },

      -- Watch mode
      watch = {
        enabled = true,
        symbol_queries = {
          python = [[
            (function_definition
              name: (identifier) @symbol)
            (class_definition
              name: (identifier) @symbol)
          ]],
          go = [[
            (function_declaration
              name: (identifier) @symbol)
            (method_declaration
              name: (field_identifier) @symbol)
          ]],
        },
      },
    })
  end,
}
