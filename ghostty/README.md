# ghostty

Tokyo Night, FiraCode Nerd Font 14pt, block cursor (no blink), copy-on-select.

`Cmd+\`` toggles the global quick terminal (needs macOS Accessibility
permission). `Left Option` is mapped to Alt so meta-keybinds work in zsh and
nvim.

Tab keybinds (`Cmd+T`, `Cmd+W`, `Cmd+Shift+[/]`) are unbound. I drive tabs from
tmux, not Ghostty.

## Install

```sh
stow ghostty       # from ~/dotfiles
```

Symlinks `.config/ghostty/` into `~/.config/`. Install FiraCode Nerd Font
separately (`brew install --cask font-fira-code-nerd-font`).
