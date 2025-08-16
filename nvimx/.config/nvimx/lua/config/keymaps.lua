local map, opts = vim.keymap.set, { noremap = true, silent = true }
map("i", "jk", "<Esc>", opts)
map("n", "<esc>", "<cmd>nohlsearch<cr>", opts)
map("n", "<leader>w", "<cmd>w<cr>", opts)
map("n", "<leader>q", "<cmd>q<cr>", opts)
-- windows
map("n", "<leader>sv", "<C-w>v", opts)
map("n", "<leader>sh", "<C-w>s", opts)
map("n", "<leader>se", "<C-w>=", opts)
map("n", "<leader>sx", "<cmd>close<cr>", opts)
-- tabs
map("n", "<leader>to", "<cmd>tabnew<cr>", opts)
map("n", "<leader>tx", "<cmd>tabclose<cr>", opts)
map("n", "<leader>tn", "<cmd>tabn<cr>", opts)
map("n", "<leader>tp", "<cmd>tabp<cr>", opts)
-- Projects picker (recent projects)
map("n", "<leader>pp", function()
  require("telescope").extensions.projects.projects({})
end, vim.tbl_extend("force", opts, { desc = "Projects (Telescope)" }))

-- Quickly re-root to detected project root (handy if you changed dirs)
map("n", "<leader>pr", "<cmd>ProjectRoot<cr>", vim.tbl_extend("force", opts, { desc = "Re-detect Project Root" }))
