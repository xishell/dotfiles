---@module "lazy"
---@type LazySpec
return {
  {
    "saghen/blink.cmp",
    version = "*",
    event = { "InsertEnter", "CmdlineEnter" },

    -- dependencies: make LuaSnip a table so version applies to it
    dependencies = {
      { "L3MON4D3/LuaSnip", version = "v2.*", build = "make install_jsregexp" },
      -- optional, but nice to have:
      -- "rafamadriz/friendly-snippets",
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

      -- super-TAB
      keymap = {
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = {
          function(cmp) return cmp.select_next() end,
          "snippet_forward",
          "fallback",
        },
        ["<S-Tab>"] = {
          function(cmp) return cmp.select_prev() end,
          "snippet_backward",
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
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
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
      -- load VSCode snippets if you use them
      pcall(function() require("luasnip.loaders.from_vscode").lazy_load() end)
      require("blink.cmp").setup(opts)
    end,
  },
}
