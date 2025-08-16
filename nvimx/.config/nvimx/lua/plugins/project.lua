return {
  {
    "ahmedkhalf/project.nvim", version = false,
    event = "VeryLazy",
    opts = {
      manual_mode = false,                         -- auto set root
      detection_methods = { "lsp", "pattern" },    -- try LSP first, then patterns
      patterns = {
        ".git", "package.json", "pyproject.toml", "requirements.txt",
        "Cargo.toml", "go.mod", "Makefile", "CMakeLists.txt",
        "pom.xml", "build.gradle", "gradlew", ".hg", ".bzr", ".svn",
      },
      ignore_lsp = {},                             -- e.g. { "efm" }
      exclude_dirs = { "~/.local/*", "~/.cargo/*" },
      show_hidden = false,
      silent_chdir = true,
      scope_chdir = "tab",                         -- per-tab roots feel great
      datapath = vim.fn.stdpath("data"),
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
      -- Telescope integration
      pcall(require("telescope").load_extension, "projects")
    end,
  },
}
