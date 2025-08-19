---@module "lazy"
---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "saghen/blink.cmp",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    -- 0) Mason first
    require("mason").setup()

    -- 1) Cache modules
    local lspconfig = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")

    -- 2) Blink capabilities
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    -- 3) On-attach keymaps (your original ones)
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(event)
        local buffer = event.buf
        local opts = { buffer = buffer, silent = true, noremap = true }
        local buf_keymaps = {
          {"n","<leader>ca","<cmd>lua vim.lsp.buf.code_action()<CR>","CodeAction"},
          {"n","<leader>cr","<cmd>lua vim.lsp.buf.rename()<CR>","Rename"},
          {"n","<leader>q","<cmd>lua vim.diagnostic.setloclist()<CR>","Open diagnostics list"},
          {"n","K","<cmd>lua vim.lsp.buf.hover()<CR>","HoverDocumentation"},
          {"n","[d","<cmd>lua vim.diagnostic.goto_prev()<CR>","Prev diagnostic"},
          {"n","]d","<cmd>lua vim.diagnostic.goto_next()<CR>","Next diagnostic"},
          {"n","cr","<cmd>lua vim.lsp.buf.rename()<CR>","Rename"},
          {"n","gD","<cmd>lua vim.lsp.buf.declaration()<CR>","GotoDeclaration"},
          {"n","gI","<cmd>lua vim.lsp.buf.incoming_calls()<CR>","IncomingCalls"},
          {"n","gO","<cmd>lua vim.lsp.buf.outgoing_calls()<CR>","OutgoingCalls"},
          {"n","gd","<cmd>lua vim.lsp.buf.definition()<CR>","GotoDefinition"},
          {"n","gi","<cmd>lua vim.lsp.buf.implementation()<CR>","GotoImplementation"},
          {"n","gl","<cmd>lua vim.diagnostic.open_float()<CR>","Float diagnostic"},
          {"n","go","<cmd>lua vim.lsp.buf.type_definition()<CR>","GotoTypeDefinition"},
          {"n","gr","<cmd>lua vim.lsp.buf.references()<CR>","GotoReferences"},
          {"n","gs","<cmd>lua vim.lsp.buf.signature_help()<CR>","SignatureHelp"},
        }
        for _, map in ipairs(buf_keymaps) do
          local modes = type(map[1]) == "table" and map[1] or { map[1] }
          for _, mode in ipairs(modes) do
            vim.keymap.set(mode, map[2], map[3], vim.tbl_extend("force", opts, { desc = map[4] }))
          end
        end
      end,
    })

    -- 4) Diagnostics UI
    local signs = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.INFO]  = "",
      [vim.diagnostic.severity.HINT]  = "",
    }
    vim.diagnostic.config({
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = function(d) return signs[d.severity] .. " " end,
      },
      signs = { text = signs },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    -- 5) Mason-lspconfig: use `handlers` inside setup (portable across versions)
    mason_lspconfig.setup({
      ensure_installed = {},          -- you said mason-tool-installer handles this
      automatic_installation = false, -- keep as you prefer
      handlers = {
        -- default handler
        function(server)
          lspconfig[server].setup({
            capabilities = capabilities,
            on_attach = function(_) end,
          })
        end,

        -- per-server overrides
        lua_ls = function()
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = { version = "LuaJIT" },
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
              },
            },
          })
        end,

        tinymist = function()
          lspconfig.tinymist.setup({
            capabilities = capabilities,
            settings = {
              exportPdf = "onSave",
              outputPath = "$root/target/$dir/$name",
            },
          })
        end,
      },
    })
  end,
}
