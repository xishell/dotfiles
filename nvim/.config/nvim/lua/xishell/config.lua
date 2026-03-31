-- Central configuration with sensible defaults
-- Override these in your local .nvim.lua file

local M = {}

-- Default configuration
M.defaults = {
  -- Notes directory paths
  notes = {
    dir = "~/notes",
    work = "~/notes/work",
    personal = "~/notes/personal",
  },

  -- Database connections (name = connection_string)
  databases = {
    -- Example: dev = "postgresql://user@localhost:5432/mydb"
  },

  -- Formatters to skip (by filetype)
  format_disabled_ft = {},

  -- LSP servers to skip
  lsp_disabled = {},
}

-- Current config (will be merged with user overrides)
M.config = vim.deepcopy(M.defaults)

--- Merge user configuration with defaults
---@param user_config table
function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", M.defaults, user_config or {})
end

--- Get a config value by dot-notation path
---@param path string e.g., "notes.dir"
---@return any
function M.get(path)
  local keys = vim.split(path, ".", { plain = true })
  local value = M.config
  for _, key in ipairs(keys) do
    if type(value) ~= "table" then
      return nil
    end
    value = value[key]
  end
  return value
end

--- Expand a path config value
---@param path string config path
---@return string
function M.get_path(path)
  local value = M.get(path)
  if type(value) == "string" then
    return vim.fn.expand(value)
  end
  return value
end

return M
