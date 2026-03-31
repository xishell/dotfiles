---@module "lazy"
---@type LazySpec
return {
  {
    "saghen/blink.cmp",
    version = "*",
    event = { "InsertEnter", "CmdlineEnter" },

    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        opts = {
          history = true,
          delete_check_events = "TextChanged",
        },
      },
    },

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },

      completion = {
        accept = { auto_brackets = { enabled = true } },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 250,
          update_delay_ms = 50,
          treesitter_highlighting = true,
          window = { border = "rounded" },
        },
        list = {
          selection = { preselect = false, auto_insert = false },
        },
        menu = {
          border = "rounded",
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind", "source_name" },
            },
            treesitter = { "lsp" },
          },
        },
      },

      -- super-TAB with smart tabout
      keymap = {
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = {
          function(cmp) return cmp.select_next() end,
          "snippet_forward",
          function()
            -- Smart tabout: only if cursor is after non-whitespace
            local col = vim.fn.col(".") - 1
            local line = vim.fn.getline(".")
            local before_cursor = line:sub(1, col)
            if before_cursor:match("^%s*$") then
              -- At beginning/whitespace only: do normal indent
              return false -- fallback to next action
            end
            -- Try tabout
            local ok, tabout = pcall(require, "tabout")
            if ok and tabout.tabout then
              tabout.tabout()
              return true
            end
            return false
          end,
          "fallback",
        },
        ["<S-Tab>"] = {
          function(cmp) return cmp.select_prev() end,
          "snippet_backward",
          function()
            -- Smart tabout backwards: only if cursor is after non-whitespace
            local col = vim.fn.col(".") - 1
            local line = vim.fn.getline(".")
            local before_cursor = line:sub(1, col)
            if before_cursor:match("^%s*$") then
              return false -- fallback to normal behavior
            end
            local ok, tabout = pcall(require, "tabout")
            if ok and tabout.taboutBack then
              tabout.taboutBack()
              return true
            end
            return false
          end,
          "fallback",
        },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-up>"] = { "scroll_documentation_up", "fallback" },
        ["<C-down>"] = { "scroll_documentation_down", "fallback" },
      },

      signature = {
        enabled = true,
        window = { border = "rounded" },
      },

      snippets = { preset = "luasnip" },

      -- regular sources stay here
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        -- Add dadbod completion for SQL files
        per_filetype = {
          sql = { "dadbod", "buffer" },
          mysql = { "dadbod", "buffer" },
          plsql = { "dadbod", "buffer" },
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
          },
          lsp = { min_keyword_length = 2, score_offset = 0 },
          path = { min_keyword_length = 0 },
          snippets = { name = "luasnip", min_keyword_length = 2 },
          buffer = { min_keyword_length = 4, max_items = 5 },
        },
      },

      -- NEW API: cmdline config moved out of sources.*
      cmdline = {
        enabled = true,
        -- keep your logic as a function (supported)
        sources = function()
          local t = vim.fn.getcmdtype()
          if t == "/" or t == "?" then
            return { "buffer" }            -- search
          elseif t == ":" then
            return { "path", "cmdline" }   -- command-line + paths
          end
          return {}
        end,
        -- (optional) cmdline-specific keymaps if you want them later
        -- keymap = { ["<CR>"] = { "accept" } },
      },
    },

    config = function(_, opts)
      -- Load snippets
      -- VSCode-style snippets (from friendly-snippets)
      require("luasnip.loaders.from_vscode").lazy_load()
      -- Custom Lua snippets
      require("luasnip.loaders.from_lua").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/lua/xishell/snippets" },
      })

      require("blink.cmp").setup(opts)
    end,
  },
}
