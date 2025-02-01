return {
  {
    "williamboman/mason.nvim",
    cmd = { "Mason" },
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    config = function(_, opts)
      require('mason').setup(opts)
    end
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = require "xishell.pconfigs.mason",
    dependencies = { "williamboman/mason.nvim" },
    cmd = {
      "MasonToolsInstall", "MasonToolsInstallSync",
      "MasonToolsUpdate", "MasonToolsUpdateSync",
      "MasonToolsClean",
    }
  },
  { "williamboman/mason-lspconfig.nvim", config = function() end },
}
