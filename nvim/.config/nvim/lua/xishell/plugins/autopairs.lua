return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    local autopairs = require("nvim-autopairs")
    autopairs.setup({
      check_ts = true,
      ts_config = {
        lua = { "string", "source" },
        javascript = { "string", "template_string" },
      },
      disable_filetype = { "TelescopePrompt", "spectre_panel" },
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
        offset = 0,
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "PmenuSel",
        highlight_grey = "LineNr",
      },
    })

    -- Add keymap to jump out of pairs
    vim.keymap.set("i", "<C-l>", function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local char = line:sub(col + 1, col + 1)

      if char:match("[%)%}%]'\"]") then
        return "<Right>"
      else
        return "<C-l>"
      end
    end, { expr = true, desc = "Jump out of pair" })
  end,
}
