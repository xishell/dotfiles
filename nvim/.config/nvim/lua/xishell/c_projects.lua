-- C/C++ Project Configuration
-- Auto-detect and add include directories for C projects

local group = vim.api.nvim_create_augroup("CProjectIncludes", { clear = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = group,
  pattern = { "*.c", "*.h", "*.cpp", "*.hpp" },
  callback = function()
    -- Get the directory containing the current file
    local file_dir = vim.fn.expand("%:p:h")

    -- Try to find project root (directory with 'include' folder)
    local project_root = file_dir
    for _ = 1, 5 do  -- Search up to 5 levels up
      local include_dir = project_root .. "/include"
      if vim.fn.isdirectory(include_dir) == 1 then
        -- Add include directory to path
        vim.opt_local.path:append(include_dir)
        break
      end
      -- Go up one directory
      project_root = vim.fn.fnamemodify(project_root, ":h")
    end

    -- Always add current directory and parent to path
    vim.opt_local.path:append(file_dir)
    vim.opt_local.path:append(vim.fn.fnamemodify(file_dir, ":h"))
  end,
})
