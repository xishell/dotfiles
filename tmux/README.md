# tmux

Prefix is `C-a`. Vim-style splits, OSC 52 clipboard, kitty graphics
passthrough, and a handful of `display-popup` shortcuts.

## Keybinds

Prefix: `C-a` (also sent through with `C-a C-a`).

| Key | Action |
|---|---|
| `C-h/j/k/l` | Move between panes and vim splits (vim-tmux-navigator) |
| `prefix -` / `\|` | Split horizontal / vertical, inherits cwd |
| `prefix c` | New window, inherits cwd |
| `prefix h` / `l` | Previous / next window |
| `prefix ←↑↓→` | Resize pane by 5 |
| `prefix x` / `&` | Kill pane / window |
| `prefix r` | Reload config |
| `prefix L` | Send `^L` (C-l is taken by vim-tmux-navigator) |

### Popups

| Key | Opens |
|---|---|
| `prefix C-y` | lazygit |
| `prefix C-g` | `gh dash` |
| `prefix C-j` | fzf session switcher |
| `prefix C-n` | New named session |
| `prefix C-t` | Throwaway shell |
| `prefix C-p` | `spotify_player` |

### Copy mode (vi)

`prefix [` to enter. `v` selects, `C-v` rectangle, `y` copies and exits.
Clipboard goes through OSC 52 (`set-clipboard on`) so yank works over SSH.

## Notable settings

- `escape-time 0` so `<Esc>` and `C-hjkl` feel instant in nvim
- `detach-on-destroy off` — killing the last session switches to another
- `base-index 1`, `pane-base-index 1`, `renumber-windows on`
- `allow-passthrough on` for kitty graphics
- `focus-events on` for nvim autoread

## Plugins

Managed by [TPM](https://github.com/tmux-plugins/tpm). After first stow:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
tmux source-file ~/.config/tmux/tmux.conf
# prefix + I to install plugins
```

- [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible)
- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)
- [tokyo-night-tmux](https://github.com/janoamaral/tokyo-night-tmux) — datetime/git
  disabled, paths shown in relative form
- [tmux-yank](https://github.com/tmux-plugins/tmux-yank)

## Install

```sh
stow tmux          # from ~/dotfiles
```

## Credits

Initial structure based on [Elliott Minns](https://github.com/elliottminns)'
config ([Dreams of Code](https://www.youtube.com/@dreamsofcode)). Diverged
substantially since.
