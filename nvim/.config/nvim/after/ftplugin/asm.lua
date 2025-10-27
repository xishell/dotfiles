-- Completely disable treesitter for assembly files
vim.b.ts_highlight = false
vim.b.ts_indent = false

-- Set assembly syntax to RISC-V
vim.g.asmsyntax = "riscv"

-- Force vim syntax highlighting
vim.schedule(function()
  -- Stop any treesitter parsing
  pcall(vim.treesitter.stop, 0)
  
  -- Clear any existing syntax
  vim.cmd("syntax clear")
  
  -- Force load assembly syntax
  vim.cmd("runtime! syntax/asm.vim")
  
  -- Ensure syntax is enabled
  vim.cmd("syntax enable")
  vim.cmd("syntax sync fromstart")
  
  -- Set buffer syntax
  vim.bo.syntax = "asm"
end)

