-- Is sofa mode on? Written by couch (~/.local/bin/couch) before it reloads Hyprland,
-- so monitors.lua and sofa.lua apply the right layout and rules on every reload.
local f = io.open(os.getenv("HOME") .. "/.local/share/couch/state.json", "r")
if not f then return false end
local state = f:read("*a")
f:close()
return state:find('"mode"%s*:%s*"sofa"') ~= nil
