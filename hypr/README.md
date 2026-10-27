# hypr

Hyprland 0.56, Lua config (`hl.*` API). `hyprland.lua` requires the modules in order.

```
.config/hypr/
├── hyprland.lua         entry point
├── hypridle.conf        lock at 5 min, screen off 1 s later
├── hyprlock.conf        lock screen (fingerprint + password)
├── hyprpaper.conf       wallpaper (wall/, rendered by theme/ember)
├── hyprsunset.conf      night light profiles
└── modules/
    ├── env.lua          cursor, Qt/GDK Wayland, NVIDIA
    ├── monitors.lua     DP-1 3440x1440@160, 10-bit, cm=edid; TV in sofa mode
    ├── look_and_feel.lua  gaps 5/10, border 2 (gradient), rounding 10, master layout
    ├── palette.lua      generated colours (theme/)
    ├── input.lua        gbswe, Windows-matched pointer (custom curve x0.5)
    ├── keybinds.lua
    ├── windowrules.lua  floats, gaming, PiP, scratchpads, smart gaps
    ├── sofa.lua         TV workspace rules, only while couch is in sofa mode
    ├── couch_state.lua  reads couch state for monitors.lua / sofa.lua
    └── autostart.lua
```

Apps are launched through `uwsm app --` so each gets its own systemd scope (needed by the 1Password SSH agent).

## Autostart

ironbar · mako · swayosd · quickshell (`mixer`, `media`) · `couch listen` · hyprpaper · hyprsunset · cliphist · gnome-keyring (secrets).
Polkit agent: `hyprpolkitagent.service` (systemd user unit).

## Keybinds

Mod = `Super`.

**Apps**

| Key | Action |
|---|---|
| `Mod Return` | kitty |
| `Mod Space` | walker (launcher) |
| `Mod X` | tools menu |
| `Mod E` / `Mod B` | dolphin / zen-browser |
| `Mod V` | clipboard history |
| `Mod Esc` | power menu (`session-end`) |
| `Mod A` / `Mod P` | mixer / media panel |
| `Mod N` / `Mod Shift N` | do not disturb / notification history |
| `Mod C` | keep awake toggle |
| `` Mod ` `` / `Mod Y` / `Mod D` | scratchpads: terminal / Spotify / Vesktop |
| `Alt Tab` | searchable window list |

**Windows**

| Key | Action |
|---|---|
| `Mod Q` | close |
| `Mod F` / `Mod T` / `Mod G` | fullscreen / float / group |
| `Mod h j k l` (or arrows) | focus |
| `Mod Shift h j k l` | move window |
| `Mod Shift Return` | swap with master |
| `Mod ,` / `Mod .` | master left / right |
| `Mod R` | resize mode (`hjkl`/arrows, `Esc` exits) |
| `Mod LMB` / `Mod RMB` | drag move / resize |

**Workspaces**

| Key | Action |
|---|---|
| `Mod 1–0` / `Mod Shift 1–0` | go to / move window to workspace 1–10 |
| `Mod Tab` | previous workspace |
| `Mod scroll` | cycle workspaces |
| `Mod S` / `Mod Shift S` | toggle / send to special workspace |

**System**

| Key | Action |
|---|---|
| `Mod Ctrl L` | lock |
| `Mod M` | quit apps cleanly, exit Hyprland |
| `Mod Ctrl R` | reload config |
| `Print` / `Shift Print` | screenshot region / monitor → satty |
| media keys | volume, brightness, player (work while locked) |

**Gaming / couch**

| Key | Action |
|---|---|
| `Mod F12` | sofa ↔ desk (`couch`) |
| `Mod F11` | Steam Big Picture |
| `Mod F10` | MangoHud: off → fps → compact → full |
| `Mod F9` | game clip start/stop |
| `Mod Shift G` | gaming mode toggle |

## Hardware assumptions

- DP-1 LG UltraGear 3440x1440 (wide gamut, `cm=edid`)
- NVIDIA (`env.lua`, `environment.d/10-nvidia-gbm.conf`)
- `gbswe` keyboard layout
- Razer mouse at 1600 DPI (udev, `system/`)
