return {
  "nvim-neorg/neorg",
  lazy = false,
  version = "*",
  config = function()
    local cfg = require("xishell.config")
    require("neorg").setup({
      load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {},
        ["core.dirman"] = {
          config = {
            workspaces = {
              notes = cfg.get("notes.dir"),
              work = cfg.get("notes.work"),
              personal = cfg.get("notes.personal"),
            },
            default_workspace = "notes",
          },
        },
      },
    })
  end,
}