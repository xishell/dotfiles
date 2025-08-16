# 🌀 Tmux Config

This repository contains a **Neovim-friendly tmux configuration**, themed with
[Tokyo Night](https://github.com/janoamaral/tokyo-night-tmux), tuned for smooth
pane navigation, mouse support, and clipboard integration.

> Config originally created by **Elliott Minns**  
> a.k.a [Dreams of Code](https://github.com/elliottminns).

---

## 🚀 Features

- Prefix remapped to **Ctrl-Space** (instead of Ctrl-b)
- Vim-style pane navigation (`h/j/k/l`)
- Seamless Neovim ↔ tmux pane movement (via `vim-tmux-navigator`)
- Truecolor and mouse support
- Start windows/panes at index 1
- Tokyo Night themed statusline
- Easy yanking with `tmux-yank`

---

## 📖 Keybind Cheat Sheet

**Prefix key:** `Ctrl-Space`

### 🔲 Panes

| Key          | Action                                |
| ------------ | ------------------------------------- |
| `Prefix + h` | Move left                             |
| `Prefix + j` | Move down                             |
| `Prefix + k` | Move up                               |
| `Prefix + l` | Move right                            |
| `Prefix + L` | Clear screen (send Ctrl-L)            |
| `Prefix + "` | Split horizontally (below, same path) |
| `Prefix + %` | Split vertically (right, same path)   |

**Without prefix**  
| Key | Action |
|-----|--------|
| `Alt + ←` | Move left |
| `Alt + →` | Move right |
| `Alt + ↑` | Move up |
| `Alt + ↓` | Move down |

---

### 🗔 Windows

| Key               | Action                 |
| ----------------- | ---------------------- |
| `Prefix + c`      | New window (same path) |
| `Shift + ←`       | Previous window        |
| `Shift + →`       | Next window            |
| `Alt + Shift + H` | Previous window        |
| `Alt + Shift + L` | Next window            |

---

### 📋 Copy Mode (vi-style)

Enter copy mode: `Prefix + [`

| Key      | Action                |
| -------- | --------------------- |
| `v`      | Begin selection       |
| `Ctrl-v` | Rectangular selection |
| `y`      | Yank (copy + exit)    |

---

## 🔌 Plugins Used

- [tmux-plugins/tpm](https://github.com/tmux-plugins/tpm) – plugin manager
- [tmux-plugins/tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) – sane defaults
- [christoomey/vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) – move between Vim & tmux panes
- [janoamaral/tokyo-night-tmux](https://github.com/janoamaral/tokyo-night-tmux) – Tokyo Night theme
- [tmux-plugins/tmux-yank](https://github.com/tmux-plugins/tmux-yank) – better yanking/clipboard

---

## 🙏 Credits

Created by [**Elliott Minns**](https://github.com/elliottminns)  
a.k.a **Dreams of Code**  
Check out his [YouTube channel](https://www.youtube.com/@dreamsofcode) for more great developer tooling content.
