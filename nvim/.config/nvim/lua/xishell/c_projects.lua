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

    -- Configure :make — detect meson project or fall back to clang
    local ext = vim.fn.expand("%:e")
    local meson_root = vim.fs.find("meson.build", { path = file_dir, upward = true, type = "file" })[1]

    if meson_root then
      local meson_dir = vim.fn.fnamemodify(meson_root, ":h")
      local builddir = meson_dir .. "/builddir"
      if vim.fn.isdirectory(builddir) == 0 then
        builddir = meson_dir .. "/build"
      end
      vim.opt_local.makeprg = "ninja -C " .. vim.fn.fnameescape(builddir)
    else
      local compiler = (ext == "cpp" or ext == "hpp") and "clang++" or "clang"
      vim.opt_local.makeprg = compiler .. " % -o %< -Wall -Wextra -g"
    end

    -- Build only
    vim.keymap.set("n", "<leader>mb", "<cmd>w<cr><cmd>make<cr>", {
      buffer = true,
      desc = "Build C/C++ file",
    })

    -- Build and run
    vim.keymap.set("n", "<leader>mr", function()
      vim.cmd("w")
      vim.cmd("make")
      local qf = vim.fn.getqflist()
      local has_errors = false
      for _, item in ipairs(qf) do
        if item.type == "E" or item.type == "e" then
          has_errors = true
          break
        end
      end
      if not has_errors then
        if meson_root then
          -- For meson projects, prompt user since executable name varies
          vim.ui.input({ prompt = "Executable to run: " }, function(exe)
            if exe and exe ~= "" then
              vim.cmd("!" .. vim.fn.fnameescape(exe))
            end
          end)
        else
          vim.cmd("!./%<")
        end
      else
        vim.cmd("copen")
      end
    end, {
      buffer = true,
      desc = "Build and run C/C++ file",
    })
  end,
})
