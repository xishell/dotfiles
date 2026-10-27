# dotfiles

macOS + CachyOS/Hyprland configs. [GNU Stow](https://www.gnu.org/software/stow/), one package per top-level dir, contents mirror `$HOME`.

## Packages

| Package | What | OS |
|---|---|---|
| `zsh` `nvim` `tmux` `git` | shell, editor, multiplexer, git | both |
| `kitty` `ghostty` `lazygit` `bat` `btop` | terminal + TUIs | both |
| `claude` | Claude Code theme | both |
| `scripts` | `~/.local/bin` + user units | both (most scripts Linux) |
| `latexmk` | global `.latexmkrc` | both |
| `aerospace` `karabiner` `config` | tiling WM, key remaps, sketchybar | macOS |
| `hypr` | Hyprland (Lua), hypridle, hyprlock, hyprpaper | Linux |
| `ironbar` `walker` `elephant` `mako` `swayosd` `quickshell` | bar, launcher, notifications, OSD, mixer/media panels | Linux |
| `gtk` `qt6ct` `mangohud` | toolkit themes, fonts, game overlay | Linux |
| `audio` | WirePlumber rules, Wave XLR recovery, AirPlay | Linux |
| `openxlr` `opendeck` | Wave XLR mixer, Stream Deck+ (dir-linked) | Linux |
| `couch` | sofa mode: TV, audio, Big Picture | Linux |
| `verimark` | fingerprint driver build + patches | Linux |

Not stowed:

| Dir | What |
|---|---|
| `theme/` | `palette.toml` → generator for every themed file ([README](theme/README.md)) |
| `system/` | root-owned files, mirror of `/etc` + `/usr` |
| `docs/` | reference notes |

## Install

```sh
git clone git@github.com:xishell/dotfiles.git ~/dotfiles && cd ~/dotfiles
```

**Linux**

```sh
./install.sh             # packages, theme, stow, dir links, user services
./install.sh --no-pkgs   # same, skip paru
system/install.sh        # diff root-owned files vs /
system/install.sh --apply   # install them (sudo); --pull copies / back into the repo
```

**macOS**

```sh
stow zsh nvim tmux git kitty ghostty lazygit bat btop claude latexmk aerospace config
ln -s ~/dotfiles/karabiner/.config/karabiner ~/.config/karabiner
```

**Uninstall:** `stow -D <package>`

## Conventions

- `--no-folding` (`.stowrc`): every file is its own symlink.
- Dir-linked, not stowed (apps save by rename, which breaks file symlinks): `karabiner`, `openxlr`, `opendeck`. Each has a `.gitignore` for runtime files.
- `.stow-local-ignore` is per package.
- Colours: never hand-edit hex; edit `theme/palette.toml` or a template, run `theme/ember`.
- zsh: numbered fragments in `zsh/.zshrc.d/`, OS-specific under `os.darwin/` / `os.linux/`.
- git: `includeIf` for KTH remotes (`~/.gitconfig-kth`), `~/.config/git/config.local` for host overrides. Neither tracked.
- Local only (never committed): couch state/TV key/venv, verimark `src/` + `dist/`, OpenXLR backups.

## More

[hypr](hypr/README.md) · [kitty](kitty/README.md) · [theme](theme/README.md) · [nvim](nvim/README.md) · [tmux](tmux/README.md) · [ghostty](ghostty/README.md) · [latexmk](latexmk/README.md) · [couch](couch/.local/share/couch/README.md) · [verimark](verimark/.local/share/verimark/README.md)
