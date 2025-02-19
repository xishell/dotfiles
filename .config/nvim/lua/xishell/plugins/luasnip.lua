return {
  "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  opts = {
    history = true,
    delete_check_events = "TextChanged",
  },
  config = function()
    local luasnip_loader = require("luasnip.loaders.from_lua")
    luasnip_loader.lazy_load({ paths = { "~/.config/nvim/lua/xishell/snippets" }})
    luasnip_loader.lazy_load()
  end,
}

