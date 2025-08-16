-- after/ftplugin/java.lua
local jdtls_ok, jdtls = pcall(require, "jdtls")
if not jdtls_ok then
  vim.notify("nvim-jdtls not available", vim.log.levels.WARN)
  return
end

-- Workspace per project (folder-name-based)
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

-- Paths from Mason
local mason = vim.fn.stdpath("data") .. "/mason/packages"
local jdtls_path = mason .. "/jdtls"
local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
local config_dir = jdtls_path .. "/config_mac"  -- macOS config folder

-- Blink capabilities (your setup)
local capabilities = require("blink.cmp").get_lsp_capabilities()

-- Basic cmd to start jdtls
local cmd = {
  "java",
  "-Declipse.application=org.eclipse.jdt.ls.core.id1",
  "-Dosgi.bundles.defaultStartLevel=4",
  "-Declipse.product=org.eclipse.jdt.ls.core.product",
  "-Dlog.protocol=true",
  "-Dlog.level=ALL",
  "-Xms1g",
  "--add-modules=ALL-SYSTEM",
  "--add-opens", "java.base/java.util=ALL-UNNAMED",
  "--add-opens", "java.base/java.lang=ALL-UNNAMED",
  "-jar", launcher,
  "-configuration", config_dir,
  "-data", workspace_dir,
}

-- Keymaps specific to Java buffers
local function on_attach(_, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end
  -- jdtls goodies
  map("n", "<leader>oi", jdtls.organize_imports, "Organize Imports")
  map("n", "<leader>ev", jdtls.extract_variable, "Extract Variable")
  map("v", "<leader>em", jdtls.extract_method, "Extract Method")
  -- You already have general LSP maps via your LspAttach; these are Java extras
end

jdtls.start_or_attach({
  cmd = cmd,
  capabilities = capabilities,
  on_attach = on_attach,
  root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
  settings = {
    java = {
      signatureHelp = { enabled = true },
      completion = { favoriteStaticMembers = {} },
      contentProvider = { preferred = "fernflower" },
    },
  },
})
