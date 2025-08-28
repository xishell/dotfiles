---@module "lazy"
---@type LazySpec
return {
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        gofmt = "gofumpt",
        goimport = "goimports-reviser",
        fillstruct = "gopls",
        dap_debug = true,
        dap_debug_keymap = true,
        dap_debug_gui = {},
        dap_debug_vt = true,
        build_tags = "",
        textobjects = true,
        test_runner = "go",
        verbose_tests = true,
        run_in_floaterm = false,
        luasnip = true,
        lsp_cfg = false, -- we handle LSP in lspconfig.lua
      })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
  },
}