-- id1206 c code needs linux headers so clangd and builds run in the lima vm
local M = {}

M.instance = "id1206"
M.host_root = vim.fs.normalize("~/courses/ID1206")
M.guest_root = "/home/elliot.guest/id1206"

function M.owns(path)
  return path ~= nil and path ~= "" and vim.startswith(vim.fs.normalize(path), M.host_root .. "/")
end

function M.to_guest(path)
  return M.guest_root .. vim.fs.normalize(path):sub(#M.host_root + 1)
end

-- sed maps vm paths back so quickfix jumps land on host files
-- comma delimiter since makeprg expands # to the alternate file
function M.wrap(cmd, host_dir)
  return string.format(
    "limactl shell --workdir %s %s %s 2>&1 | sed 's,%s,%s,g'",
    vim.fn.shellescape(M.to_guest(host_dir)),
    M.instance,
    cmd,
    M.guest_root,
    M.host_root
  )
end

return M
