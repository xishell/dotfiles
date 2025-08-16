return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- macOS UX polish (no plugin; just config on load)
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
    init = function()
      if vim.loop.os_uname().sysname == "Darwin" then
        -- Clipboard is already good with unnamedplus, but ensure it’s used
        vim.opt.clipboard = "unnamedplus"

        -- Faster redraws when holding keys in iTerm/Kitty
        vim.opt.ttyfast = true

        -- If you installed Python via Homebrew, uncomment:
        -- vim.g.python3_host_prog = "/opt/homebrew/bin/python3"
      end
    end,
  },

  -- fzf-native needs CLT; safe to load lazily
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = function()
      return vim.fn.executable("make") == 1
    end,
  },
}
