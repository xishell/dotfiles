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
          {"n","<leader>cd","<cmd>lua vim.diagnostic.setloclist()<CR>","Document diagnostics"},
          {"n","<leader>cD","<cmd>lua vim.diagnostic.setqflist()<CR>","Workspace diagnostics"},

          {"n","K","<cmd>lua vim.lsp.buf.hover()<CR>","HoverDocumentation"},
          {"n","[d","<cmd>lua vim.diagnostic.goto_prev()<CR>","Prev diagnostic"},
          {"n","]d","<cmd>lua vim.diagnostic.goto_next()<CR>","Next diagnostic"},
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

    -- 5) Per-server config, mason-lspconfig v2 dropped `handlers` and only calls vim.lsp.enable
    vim.lsp.config("*", { capabilities = capabilities })

    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    })

    vim.lsp.config("tinymist", {
      settings = {
        exportPdf = "onSave",
        outputPath = "$root/target/$dir/$name",
      },
    })

    vim.lsp.config("gopls", {
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
          },
          staticcheck = true,
          gofumpt = true,
        },
      },
    })

    local lima = require("xishell.lima")
    local clangd_markers = {
      ".clangd", ".clang-tidy", ".clang-format",
      "compile_commands.json", "compile_flags.txt", "configure.ac", ".git",
    }

    vim.lsp.config("clangd", {
      -- query-driver lets clangd read newlib headers from arm gcc for stm32
      -- iwyu mode adds the declaring header even when already visible transitively
      cmd = {
        "clangd",
        "--query-driver=/opt/homebrew/bin/arm-none-eabi-*",
        "--header-insertion=never",
      },
      filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" }, -- no asm, riscv files go elsewhere
      root_dir = function(bufnr, on_dir)
        local name = vim.api.nvim_buf_get_name(bufnr)
        if lima.owns(name) then return end -- clangd_lima takes these
        on_dir(vim.fs.root(bufnr, clangd_markers) or vim.fs.dirname(name))
      end,
    })

    -- macos clangd lacks cpu_set_t and kernel headers, vm clangd sees the real ones
    vim.lsp.config("clangd_lima", {
      cmd = {
        "limactl", "shell", "--workdir", lima.guest_root, lima.instance,
        "clangd",
        "--path-mappings=" .. lima.host_root .. "=" .. lima.guest_root,
        "--header-insertion=never",
      },
      filetypes = { "c", "cpp" },
      root_dir = function(bufnr, on_dir)
        if lima.owns(vim.api.nvim_buf_get_name(bufnr)) then
          -- markers above the course resolve to ~ which the vm cannot map
          local root = vim.fs.root(bufnr, clangd_markers)
          on_dir(lima.owns(root) and root or lima.host_root)
        end
      end,
    })
    vim.lsp.enable("clangd_lima")

    vim.lsp.config("ltex", {
      -- jdk 24+ caps xml entity size below languagetool's grammar.xml
      cmd_env = {
        JAVA_OPTS = "-Djdk.xml.totalEntitySizeLimit=0",
      },
      settings = {
        ltex = {
          disabledRules = {
            ["en-US"] = { "MORFOLOGIK_RULE_EN_US" },
            ["en"]    = { "MORFOLOGIK_RULE_EN" },
          },
        },
      },
    })

    -- 6) Mason-lspconfig enables installed servers, asm_lsp clashes with riscv assembly
    mason_lspconfig.setup({
      ensure_installed = {}, -- mason-tool-installer handles installs
      automatic_enable = { exclude = { "asm_lsp" } },
    })
  end,
}
