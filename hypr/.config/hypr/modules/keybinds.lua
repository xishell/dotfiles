local mainMod     = "SUPER"
local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "walker -H"   -- -H: no F-key chips; a second press closes it
local tools       = "menu-tools"
local browser     = "zen-browser"

-- Core app launchers / window actions
hl.bind(mainMod .. " + Return",      hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",           hl.dsp.window.close())
hl.bind(mainMod .. " + space",       hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + X",           hl.dsp.exec_cmd(tools))
hl.bind(mainMod .. " + M",           hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E",           hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B",           hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + T",           hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + G",           hl.dsp.group.toggle())
-- Clipboard history and power menu (walker providers)
hl.bind(mainMod .. " + V",           hl.dsp.exec_cmd("walker -m clipboard"))
hl.bind(mainMod .. " + Escape",      hl.dsp.exec_cmd("walker -m menus:power -t ember-power"))
hl.bind(mainMod .. " + A",           hl.dsp.exec_cmd("qs -c mixer ipc call mixer toggle"))
hl.bind(mainMod .. " + P",           hl.dsp.exec_cmd("qs -c media ipc call media toggle"))
hl.bind(mainMod .. " + F",           hl.dsp.window.fullscreen())
-- Back to the last-used workspace (cycling is Super+scroll)
hl.bind(mainMod .. " + Tab",         hl.dsp.focus({ workspace = "previous" }))

-- Move focus with arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move focus with vim keys
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Move windows with arrow keys
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Move windows with vim keys
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down" }))

-- Master layout
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.layout("swapwithmaster"))
hl.bind(mainMod .. " + comma",          hl.dsp.layout("orientationleft"))
hl.bind(mainMod .. " + period",         hl.dsp.layout("orientationright"))

-- Resize submap (SUPER + R to enter, Escape/Return to exit)
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("h",     hl.dsp.window.resize({ x = -20, y = 0 }),  { repeating = true })
    hl.bind("l",     hl.dsp.window.resize({ x = 20,  y = 0 }),  { repeating = true })
    hl.bind("k",     hl.dsp.window.resize({ x = 0,   y = -20 }), { repeating = true })
    hl.bind("j",     hl.dsp.window.resize({ x = 0,   y = 20 }),  { repeating = true })
    hl.bind("left",  hl.dsp.window.resize({ x = -20, y = 0 }),  { repeating = true })
    hl.bind("right", hl.dsp.window.resize({ x = 20,  y = 0 }),  { repeating = true })
    hl.bind("up",    hl.dsp.window.resize({ x = 0,   y = -20 }), { repeating = true })
    hl.bind("down",  hl.dsp.window.resize({ x = 0,   y = 20 }),  { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
end)

-- Workspaces 1-10 (10 maps to key 0)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll workspaces with the mouse wheel
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with SUPER + LMB/RMB drag
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media + brightness keys through swayosd (OSD; volume capped at 100 %).
-- locked = works while screen is locked, repeating = autorepeat
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume lower"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),   { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("swayosd-client --brightness raise"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"),                  { locked = true, repeating = true })

-- Player keys
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Screenshot region → clipboard + ~/Pictures/Screenshots/
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | tee ~/Pictures/Screenshots/$(date +%F_%H-%M-%S).png | wl-copy'))

-- Reload config
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("hyprctl reload"))

-- Gaming mode toggle
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd("gaming-mode-toggle"))
