return {
  "nvim-neorg/neorg",
  lazy = false,
  version = "*",
  config = function()
    require("neorg").setup({
      load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {},
        ["core.dirman"] = {
          config = {
            workspaces = {
              notes = "~/notes",
              work = "~/notes/work",
              personal = "~/notes/personal",
            },
            default_workspace = "notes",
          },
        },
      },
    })
  end,
}