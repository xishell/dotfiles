#!/usr/bin/env bash
# Bootstrap the CachyOS + Hyprland "Hearth" desktop from this repo.
#   ./install.sh            packages, theme, stow, user services
#   ./install.sh --no-pkgs  skip the paru sync
# macOS / servers: stow packages by hand instead (see README.md).
set -euo pipefail
cd "$(dirname "$0")"

# Shared (mac + linux) and Linux-only stow packages
SHARED=(zsh nvim tmux git kitty lazygit bat btop scripts)
LINUX=(hypr ironbar walker elephant mako swayosd mangohud gtk qt6ct fuzzel quickshell)

if [[ ${1:-} != --no-pkgs ]]; then
    command -v paru >/dev/null || { echo "install paru first (CachyOS: pacman -S paru)"; exit 1; }
    grep -hv '^\s*\(#\|$\)' pkglist.txt | sudo pacman -S --needed -
    grep -hv '^\s*\(#\|$\)' pkglist-aur.txt | paru -S --needed --aur -
fi

# Colours: every themed config is generated from theme/palette.toml
theme/ember

for pkg in "${SHARED[@]}" "${LINUX[@]}"; do
    [[ -d $pkg ]] && stow --restow "$pkg"
done

# bat reads themes from a cache; btop's own btop.conf (not tracked) picks the theme
command -v bat >/dev/null && bat cache --build >/dev/null
[ -f "$HOME/.config/btop/btop.conf" ] && sed -i 's/^color_theme = .*/color_theme = "ember"/' "$HOME/.config/btop/btop.conf"

# MangoHud.conf is a symlink the `hud` script moves between layouts; start with "off"
[ -e "$HOME/.config/MangoHud/MangoHud.conf" ] || scripts/.local/bin/hud off

systemctl --user daemon-reload
for unit in hyprpolkitagent.service elephant.service walker.service; do
    systemctl --user list-unit-files "$unit" >/dev/null 2>&1 && systemctl --user enable --now "$unit" || true
done
echo "done. Log out and pick the Hyprland (uwsm) session."
