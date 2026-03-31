-- Example local config file
-- Copy this to ~/.nvim.lua or <project>/.nvim.lua to override defaults
--
-- The file must return a table that will be merged with defaults

return {
  -- Notes directory paths
  notes = {
    dir = "~/notes",
    work = "~/notes/work",
    personal = "~/notes/personal",
  },

  -- Database connections for vim-dadbod
  -- Format: name = "connection_string"
  databases = {
    dev = "postgresql://user@localhost:5432/mydb",
    staging = "postgresql://user@staging-host:5432/mydb",
  },

  -- Disable formatting for specific filetypes
  format_disabled_ft = {
    -- "markdown",
    -- "json",
  },

  -- Disable specific LSP servers
  lsp_disabled = {
    -- "tsserver",
  },
}
