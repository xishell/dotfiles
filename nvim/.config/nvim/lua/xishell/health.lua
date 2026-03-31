-- Health check for xishell config
-- Run with :checkhealth xishell

local M = {}

local health = vim.health

function M.check()
  health.start("xishell configuration")

  -- Check vim.loader
  if vim.loader and vim.loader.enabled then
    health.ok("vim.loader is enabled (faster startup)")
  else
    health.warn("vim.loader is not enabled", { "Add `vim.loader.enable()` to init.lua" })
  end

  -- Check leader keys
  if vim.g.mapleader == " " then
    health.ok("Leader key is set to <Space>")
  else
    health.info("Leader key: " .. vim.inspect(vim.g.mapleader))
  end

  -- Check notes directory
  local cfg = require("xishell.config")
  local notes_dir = cfg.get_path("notes.dir")
  if vim.fn.isdirectory(notes_dir) == 1 then
    health.ok("Notes directory exists: " .. notes_dir)
  else
    health.warn("Notes directory not found: " .. notes_dir, {
      "Create the directory or update notes.dir in ~/.nvim.lua",
    })
  end

  -- Check for local config
  local local_config_paths = {
    vim.fn.getcwd() .. "/.nvim.lua",
    vim.fn.expand("~/.nvim.lua"),
  }
  local found_local = false
  for _, path in ipairs(local_config_paths) do
    if vim.fn.filereadable(path) == 1 then
      health.ok("Local config found: " .. path)
      found_local = true
    end
  end
  if not found_local then
    health.info("No local config override found (optional)")
  end

  -- Check essential external tools
  health.start("External tools")

  local tools = {
    { cmd = "git", required = true, desc = "Version control" },
    { cmd = "rg", required = true, desc = "Ripgrep (faster grep)" },
    { cmd = "fd", required = false, desc = "Fast file finder" },
    { cmd = "lazygit", required = false, desc = "Git TUI" },
    { cmd = "node", required = false, desc = "Node.js (for some LSPs)" },
  }

  for _, tool in ipairs(tools) do
    if vim.fn.executable(tool.cmd) == 1 then
      health.ok(tool.cmd .. " found (" .. tool.desc .. ")")
    elseif tool.required then
      health.error(tool.cmd .. " not found", { "Install " .. tool.cmd .. " - " .. tool.desc })
    else
      health.warn(tool.cmd .. " not found (optional)", { tool.desc })
    end
  end

  -- Check formatters from conform
  health.start("Formatters (conform.nvim)")

  local formatters = {
    { cmd = "stylua", ft = "lua" },
    { cmd = "prettierd", ft = "js/ts/json/yaml/md" },
    { cmd = "shfmt", ft = "sh/bash/zsh" },
    { cmd = "black", ft = "python" },
    { cmd = "clang-format", ft = "c/cpp" },
    { cmd = "gofumpt", ft = "go" },
  }

  local missing_formatters = {}
  for _, fmt in ipairs(formatters) do
    if vim.fn.executable(fmt.cmd) == 1 then
      health.ok(fmt.cmd .. " (" .. fmt.ft .. ")")
    else
      table.insert(missing_formatters, fmt.cmd)
    end
  end

  if #missing_formatters > 0 then
    health.warn("Missing formatters: " .. table.concat(missing_formatters, ", "), {
      "Run :Mason to install missing tools",
    })
  end

  -- Check LSP servers
  health.start("LSP servers")

  local lsp_servers = {
    { cmd = "lua-language-server", ft = "lua" },
    { cmd = "clangd", ft = "c/cpp" },
    { cmd = "gopls", ft = "go" },
    { cmd = "typescript-language-server", ft = "typescript/javascript" },
    { cmd = "tinymist", ft = "typst" },
  }

  for _, lsp in ipairs(lsp_servers) do
    if vim.fn.executable(lsp.cmd) == 1 then
      health.ok(lsp.cmd .. " (" .. lsp.ft .. ")")
    else
      health.info(lsp.cmd .. " not found (" .. lsp.ft .. ")")
    end
  end

  -- Check plugin status
  health.start("Plugin health")

  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    local stats = lazy.stats()
    health.ok(string.format("Lazy.nvim: %d plugins (%d loaded)", stats.count, stats.loaded))
    if stats.startuptime then
      health.info(string.format("Startup time: %.2f ms", stats.startuptime))
    end
  else
    health.error("Lazy.nvim not found")
  end

  -- Check for common issues
  health.start("Common issues check")

  -- Check if clipboard provider is available
  if vim.fn.has("clipboard") == 1 then
    health.ok("Clipboard provider available")
  else
    health.warn("No clipboard provider", { "Install xclip, xsel, or wl-copy" })
  end

  -- Check termguicolors
  if vim.opt.termguicolors:get() then
    health.ok("termguicolors enabled")
  else
    health.warn("termguicolors not enabled")
  end

  -- Check undofile directory
  local undodir = vim.fn.expand(vim.opt.undodir:get()[1] or "")
  if undodir ~= "" and vim.fn.isdirectory(undodir) == 1 then
    health.ok("Undo directory exists: " .. undodir)
  elseif vim.opt.undofile:get() then
    health.warn("undofile enabled but directory may not exist")
  end
end

return M
