return {
  'echasnovski/mini.surround',
  version = '*',
  config = function()
    require('mini.surround').setup({
      mappings = {
        add = 'ys',             -- Add surrounding (e.g. ysiw) )
        delete = 'ds',          -- Delete surrounding (e.g. ds) )
        replace = 'cs',         -- Change surrounding (e.g. cs)' )
        find = '',              -- Disabled
        find_left = '',         -- Disabled
        highlight = '',         -- Disabled
        update_n_lines = '',    -- Disabled
        suffix_last = '',       -- Disabled
        suffix_next = '',       -- Disabled
      },
    })
    -- Classic visual-mode S to add surrounding
    vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { desc = 'Add Surrounding' })
  end,
}