return {
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "0.3.*",
    build = function()
      require("typst-preview").update()
    end,
    opts = {
      dependencies_bin = {
        ["tinymist"] = "tinymist",
        ["websocat"] = "websocat",
      },
      open_cmd = "open %s",
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