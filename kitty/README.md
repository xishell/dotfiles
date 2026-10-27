# kitty

tmux-style prefix keys, sessions, splits, custom tab bar. Shared by macOS and Linux.

```
.config/kitty/
├── kitty.conf          main config, keys
├── ember.conf          colours (generated, theme/)
├── os.linux.conf       FiraCode Nerd Font 12
├── os.macos.conf       Fira Code 14
├── tab_bar.py          custom tab bar, colour block generated
├── nav.py              ctrl+hjkl across splits → Hyprland windows
├── scripts/            session picker (floating panel)
└── sessions/           startup session
```

`os.${KITTY_OS}.conf` is picked per OS.

## Keys

Prefix: `ctrl+a`. One action, then back to normal (`esc` cancels, `ctrl+a ctrl+a` sends it through).

**Windows and tabs**

| Key | Action |
|---|---|
| `\|` / `-` | split vertical / horizontal (cwd) |
| `z` | zoom (stack layout) |
| `x` / `&` | close split / tab |
| `c` (or `cmd+t`) | new tab (cwd) |
| `h` / `l` | previous / next tab |
| `1`–`9` | go to tab |
| arrows | resize split |
| `ctrl+h j k l` (no prefix) | focus split; at the edge, the next Hyprland window |

**Sessions**

| Key | Action |
|---|---|
| `ctrl+j` / `ctrl+s` | pick session |
| `ctrl+n` | new session |
| `ctrl+o` | previous session |
| `X` | close session |

**Scrollback and hints**

| Key | Action |
|---|---|
| `[` | scrollback in pager |
| `g` | last command output |
| `k` / `j` | previous / next prompt |
| `u` | open URL |
| `f` | paste a path at the prompt |

**Overlays**

| Key | Opens |
|---|---|
| `ctrl+y` | lazygit |
| `ctrl+g` | `gh dash` |
| `ctrl+t` | throwaway shell |
| `ctrl+p` | spotify_player |

**Other:** `r` reload config · `L` send `ctrl+l`

## Settings

- Layouts: `splits`, `stack`. Tab bar at the bottom.
- Copy on select. No close confirmation.
- Bell: no sound; the window/tab is flagged instead.
- Notification when a command over 15 s finishes in an unfocused window.
- Scrollback 20 000 lines.
- Remote control over a per-instance socket (`/tmp/kitty-<pid>`), needed by `nav.py` and the session picker.
- nvim gets `ctrl+hjkl` itself (`IS_NVIM`), and hands off at its edges the same way.
