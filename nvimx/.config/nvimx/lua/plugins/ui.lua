return {
  { "folke/tokyonight.nvim",
        name = "tokyonight",
        priority = 1000,
        config = function() 
            vim.cmd([[colorscheme tokyonight-night]])
        end,
  },
  { "nvim-lualine/lualine.nvim", opts = { options = { theme = "auto" } } },
  { "akinsho/bufferline.nvim", version = "*", opts = {} },
  {
    "lewis6991/gitsigns.nvim",
    opts = { signs = { add = { text = "│" }, change = { text = "│" }, delete = { text = "_" } } },
  },
}
