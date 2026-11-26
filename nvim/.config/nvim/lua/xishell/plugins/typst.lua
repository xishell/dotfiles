return {
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    build = function()
      require("typst-preview").update()
    end,
    opts = {
      -- share Mason's tinymist with the LSP; the plugin downloads websocat itself
      dependencies_bin = { tinymist = "tinymist" },
      open_cmd = vim.fn.has("mac") == 1 and "open %s" or nil,
      invert_colors = "auto",
      follow_cursor = true,
      debug = false,
    },
    keys = {
      { "<localleader>tp", "<cmd>TypstPreview<CR>", ft = "typst", desc = "Start Preview" },
      { "<localleader>ts", "<cmd>TypstPreviewStop<CR>", ft = "typst", desc = "Stop Preview" },
      { "<localleader>tt", "<cmd>TypstPreviewToggle<CR>", ft = "typst", desc = "Toggle Preview" },
      { "<localleader>tf", "<cmd>TypstPreviewFollowCursorToggle<CR>", ft = "typst", desc = "Toggle Follow Cursor" },
      { "<localleader>tc", "<cmd>TypstPreviewSyncCursor<CR>", ft = "typst", desc = "Sync Cursor" },
    },
  },
}