return {
  {
    "chomosuke/typst-preview.nvim",
    lazy = false,
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
  },
}