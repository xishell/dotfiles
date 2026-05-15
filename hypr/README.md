# hypr

Hyprland config written in Lua. Each topic lives in its own module under
`modules/`; `hyprland.lua` just `require`s them in order.

```
.config/hypr/
├── hyprland.lua            # entry point
├── hyprpaper.conf          # wallpaper
├── hypridle.conf           # DPMS off after 5 min
└── modules/
    ├── env.lua             # XCURSOR, Qt/GDK Wayland hints, Nvidia, permissions
    ├── monitors.lua        # DP-1 + HDMI-A-1
    ├── look_and_feel.lua   # gaps, borders, blur, animations, master layout
    ├── input.lua           # gbswe layout, touchpad, sensitivity
    ├── keybinds.lua        # see below
    ├── windowrules.lua     # floats, gaming, PiP, opacity
    └── autostart.lua       # waybar, hyprpaper, hypridle, cliphist, keyring
```

The Lua entrypoint requires a Hyprland build with the Lua API enabled (`hl.*`
globals). It is roughly a 1:1 port of the equivalent `hyprland.conf` — see
commit `dc271d1`.

## Hardware assumptions

The config is set up for my personal box and will need edits on other
hardware:

- **Monitor:** `DP-1` at `3440x1440@160`, `HDMI-A-1` disabled (`monitors.lua`)
- **GPU:** Nvidia env vars set in `env.lua` (`LIBVA_DRIVER_NAME`,
  `GBM_BACKEND`, `WLR_NO_HARDWARE_CURSORS=1`). Harmless on AMD/Intel but you
  can delete that block.
- **Keyboard:** `gbswe` layout (`input.lua`) — Swedish hardware, UK-ish
  layout.

## Apps it expects

Spawned from keybinds or autostart. Install whichever you actually want;
missing binaries just no-op the bind.

```
kitty dolphin zen-browser otter-launcher hyprshutdown
waybar hyprpaper hypridle hyprpolkitagent easyeffects
grim slurp wl-copy wl-clipboard cliphist
brightnessctl playerctl wpctl gnome-keyring
```

Companion configs live elsewhere in this repo: `waybar/`, `wofi/`,
`otter-launcher/`, `hyprlauncher/`, `gtk/`, `alacritty/`.

## Keybinds

Mod is `SUPER`.

### Apps and windows

| Key | Action |
|---|---|
| `Mod + Return` | kitty |
| `Mod + Space` | otter-launcher (kitty floating) |
| `Mod + E` | dolphin |
| `Mod + B` | zen-browser |
| `Mod + Q` | close window |
| `Mod + V` | toggle floating |
| `Mod + F` | fullscreen |
| `Mod + M` | `hyprshutdown` if installed, else exit Hyprland |
| `Mod + Shift + G` | `gaming-mode-toggle` |

### Focus and movement

`Mod + h/j/k/l` or `Mod + arrows` to move focus. `Mod + Shift + …` moves the
window in that direction. Same applies to workspaces:

| Key | Action |
|---|---|
| `Mod + 1..9, 0` | Workspace 1–10 |
| `Mod + Shift + 1..9, 0` | Move window to workspace |
| `Mod + Tab` / `Shift + Tab` | Next / previous workspace |
| `Mod + scroll` | Cycle workspaces |
| `Mod + S` | Toggle special workspace ("magic") |
| `Mod + Shift + S` | Send window to special workspace |
| `Mod + LMB` / `RMB` drag | Move / resize window |

### Layout (master)

| Key | Action |
|---|---|
| `Mod + Shift + Return` | Swap with master |
| `Mod + ,` | Orientation left |
| `Mod + .` | Orientation right |
| `Mod + R` | Enter resize submap (`hjkl` or arrows, `Esc`/`Return` exits) |

### Media

Standard `XF86Audio*` and `XF86MonBrightness*` keys. Volume and brightness
step by 5 %, work while the screen is locked, and autorepeat.

### Screenshots

`Print` runs `grim -g "$(slurp)"`, pipes the PNG into both
`~/Pictures/Screenshots/<timestamp>.png` and the clipboard via `wl-copy`.

## Notable settings

- **Theme:** Tokyo Night borders (`#7aa2f7` → `#bb9af7`, 45°), 10px rounding,
  shadows + blur on
- **Layout:** master, `mfact = 0.55`, new windows go to slave stack
- **Animations:** custom bezier set (`easeOutQuint`, `quick`, …) per-leaf
- **Touchpad:** flat accel profile, sensitivity `-0.75`, disable-while-typing
- **Idle:** screen off after 5 min (`hypridle.conf`)
- **Window rules:** suppresses `maximize` events globally, floats common
  dialogs / system tools / yazi / Steam subwindows, keeps mpv-vlc-firefox
  awake on fullscreen, `idle_inhibit` for Steam games and gamescope
