# dotfiles

My personal configs. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

Each top-level directory is a stow package whose contents mirror `$HOME`. For
example, `nvim/.config/nvim/` ends up at `~/.config/nvim/` after stowing.

## Layout

```
.
├── .stowrc                 # --target=~ --no-folding
├── .stow-local-ignore      # files Stow shouldn't link (README, LICENSE, …)
├── zsh/                    # .zshenv, .zshrc, .zshrc.d/
├── nvim/                   # .config/nvim/
├── tmux/                   # .config/tmux/
├── git/                    # .config/git/
├── scripts/                # .local/bin/ + user units (couch, audio-mode, hud, …)
├── kitty/ ghostty/ claude/ # shared
├── hypr/ ironbar/ walker/ elephant/ mako/ swayosd/ mangohud/ gtk/ qt6ct/ quickshell/
├── audio/ couch/ verimark/ # Linux: PipeWire/WirePlumber, sofa mode, fingerprint driver
├── openxlr/ opendeck/      # Linux: linked as whole directories (apps replace files on save)
├── theme/                  # not stowed; palette.toml → generator for every themed config
├── system/                 # not stowed; root-owned files, mirror of /etc + /usr (install.sh)
├── aerospace/ karabiner/   # macOS
└── docs/                   # not stowed; reference notes
```

## Install

```sh
git clone https://github.com/xishell/dotfiles ~/dotfiles
cd ~/dotfiles
stow zsh nvim tmux git scripts
```

Stow with `--no-folding` (set in `.stowrc`), so each leaf file gets its own
symlink and you can stow a new package later without re-folding existing dirs.

Per-host: pick the packages that apply. There is no `bootstrap.sh` because the
right set of packages on a laptop is not the right set on a server.

### macOS

```sh
stow aerospace karabiner
```

`karabiner.json` is 55k of remappings; expect to edit it through the Karabiner
GUI rather than by hand.

### Linux (Hyprland)

```sh
./install.sh            # packages, theme, stow, directory links, user services
system/install.sh       # diff root-owned files against /; --apply installs them with sudo
```

The Hyprland config was ported to Lua (see commit `dc271d1`).

OpenXLR and OpenDeck save by writing a new file and renaming it over the old one,
which would replace a per-file stow symlink. Their config directories are therefore
symlinked whole (`~/.config/openxlr` → `openxlr/.config/openxlr`), with a
`.gitignore` per package so only real config is tracked. `couch` keeps its state,
log, venv and TV pairing key in `~/.local/share/couch`, outside git.

## Conventions

**zsh** is split into ordered fragments under `zsh/.zshrc.d/`:

```
00-exports.zsh    30-options.zsh    60-integrations.zsh
10-zinit.zsh      40-aliases.zsh    os.darwin/   # sourced on macOS
20-completion.zsh 50-functions.zsh  os.linux/    # sourced on Linux
```

Add new shell config to a numbered fragment, not to `.zshrc` itself.
OS-specific bits go under `os.darwin/` or `os.linux/`.

**git** uses `includeIf` so KTH remotes (`gits-15.sys.kth.se`) pick up
`~/.gitconfig-kth`, and `~/.config/git/config.local` is included unconditionally
for host-local overrides. Neither file is tracked here.

## Subdirectory READMEs

A few packages have their own notes:

- [`nvim/README.md`](nvim/README.md) — keymaps, plugin list, `:checkhealth xishell`
- [`tmux/README.md`](tmux/README.md) — prefix is `C-a`, vim-style splits
- [`hypr/README.md`](hypr/README.md) — Lua-configured Hyprland, modular layout
- [`ghostty/README.md`](ghostty/README.md)
- [`latexmk/README.md`](latexmk/README.md)

## Uninstall

```sh
cd ~/dotfiles
stow -D <package>
```

Stow only removes the symlinks it owns. Anything you edited through a GUI
(Karabiner, GTK) stays put.
