return {
  "abecodes/tabout.nvim",
  lazy = true, -- loaded by blink.cmp when needed
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    tabkey = "", -- disabled, blink.cmp handles Tab
    backwards_tabkey = "", -- disabled, blink.cmp handles S-Tab
    act_as_tab = true,
    act_as_shift_tab = false,
    default_tab = "<C-t>",
    default_shift_tab = "<C-d>",
    enable_backwards = true,
    completion = false, -- blink.cmp handles completion
    tabouts = {
      { open = "'", close = "'" },
      { open = '"', close = '"' },
      { open = "`", close = "`" },
      { open = "(", close = ")" },
      { open = "[", close = "]" },
      { open = "{", close = "}" },
    },
    ignore_beginning = true,
    exclude = {},
  },
}
