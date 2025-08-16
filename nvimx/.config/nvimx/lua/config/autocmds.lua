local aug = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local tidy = aug("Tidy", { clear = true })

autocmd("TextYankPost", { group = tidy, callback = function() vim.highlight.on_yank() end })
autocmd("VimResized", { group = tidy, callback = function() vim.cmd("tabdo wincmd =") end })
