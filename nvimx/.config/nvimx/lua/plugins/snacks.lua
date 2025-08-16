return {
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      explorer = {
        enabled = true,
        -- You can keep this defaulted; keys below pass an explicit cwd
        focus = "input",
        jump = { close = true },
      },
      notifier = { enabled = true },
      bufdelete = { enabled = true },
      terminal = { enabled = true },
      statuscolumn = { enabled = true },
    },
    keys = {
      -- Open Explorer at *project root* (project.nvim sets cwd to root already,
      -- but we ask Snacks for the root explicitly for clarity).
      { "<leader>e", function()
          require("snacks").explorer({ cwd = require("snacks.root").get() })
        end, desc = "Explorer (root)" },

      -- Open Explorer at *current working directory* (whatever :pwd is)
      { "<leader>E", function()
          require("snacks").explorer({ cwd = vim.loop.cwd() })
        end, desc = "Explorer (cwd)" },
    },
  },
}
