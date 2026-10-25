-- Sofa mode: a "tv" workspace on the TV for Steam Big Picture and the games it starts,
-- while the desk monitor keeps working normally. Only active while couch says so;
-- loaded after windowrules.lua so these rules win (e.g. over float-steam-subwindows).
if not require("modules.couch_state") then return end

-- Keep the normal workspaces on the desk: without this, Hyprland hands the TV an
-- existing workspace (e.g. 1, windows and all) when it comes on
for i = 1, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1" })
end

hl.workspace_rule({
    workspace  = "name:tv",
    monitor    = "HDMI-A-1",
    default    = true,
    persistent = true,
})

hl.window_rule({
    name       = "sofa-big-picture",
    match      = { class = "^steam$", title = "^Steam Big Picture Mode$" },
    workspace  = "name:tv",
    tile       = true,
    fullscreen = true,
})

-- Games: Proton/Wine titles are steam_app_<id>; add native games' classes here
hl.window_rule({
    name       = "sofa-games",
    match      = { class = "^(steam_app_.*|gamescope)$" },
    workspace  = "name:tv",
    fullscreen = true,
})
