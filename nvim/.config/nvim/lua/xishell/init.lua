vim.g.mapleader = " "
vim.g.maplocalleader = "'"
vim.opt.termguicolors = true

-- Load central config (before plugins)
local config = require("xishell.config")

-- Load local config overrides if present (.nvim.lua in cwd or home)
local function load_local_config()
  local local_configs = {
    vim.fn.getcwd() .. "/.nvim.lua",
    vim.fn.expand("~/.nvim.lua"),
  }
  for _, path in ipairs(local_configs) do
    if vim.fn.filereadable(path) == 1 then
      local ok, user_config = pcall(dofile, path)
      if ok and type(user_config) == "table" then
        config.setup(user_config)
      elseif not ok then
        vim.notify("Error loading " .. path .. ": " .. tostring(user_config), vim.log.levels.WARN)
      end
    end
  end
end
load_local_config()

-- Custom filetype detection
vim.filetype.add({
  extension = {
    typ = "typst",
  },
})

require("xishell.lazy_init")
require("xishell.options")
require("xishell.keymaps")
require("xishell.auto")
require("xishell.c_projects")
