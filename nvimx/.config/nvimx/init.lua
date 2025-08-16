-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({"git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git","--branch=stable", lazypath})
    end
    vim.opt.rtp:prepend(lazypath)

-- Core editor settings
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Plugin imports
require("lazy").setup({
  { import = "plugins" },        -- pulls: plugins/*.lua
  { import = "plugins.lsp" },    -- pulls: plugins/lsp/*.lua
}, {
  ui = { border = "rounded" },
  change_detection = { notify = false },
})
