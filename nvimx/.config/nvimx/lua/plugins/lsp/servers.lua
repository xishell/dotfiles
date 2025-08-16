local M = {}

function M.setup()
  local lsp = require("lspconfig")
  local caps = require("cmp_nvim_lsp").default_capabilities()

  local on_attach = function(_, bufnr)
    local map = function(mode, lhs, rhs) vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true }) end
    map("n", "gd", vim.lsp.buf.definition)
    map("n", "gr", vim.lsp.buf.references)
    map("n", "K", vim.lsp.buf.hover)
    map("n", "<leader>rn", vim.lsp.buf.rename)
    map("n", "<leader>ca", vim.lsp.buf.code_action)
    map("n", "[d", vim.diagnostic.goto_prev)
    map("n", "]d", vim.diagnostic.goto_next)
  end

  local servers = { "lua_ls", "clangd", "pyright", "jsonls", "yamlls" }
  for _, s in ipairs(servers) do
    if s == "lua_ls" then
      lsp.lua_ls.setup({
        on_attach = on_attach,
        capabilities = caps,
        settings = { Lua = { diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false } } },
      })
    else
      lsp[s].setup({ on_attach = on_attach, capabilities = caps })
    end
  end
end

return M
