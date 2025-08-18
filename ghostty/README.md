# Ghostty Terminal Configuration

Modern GPU-accelerated terminal emulator configuration.

## Features

- **Theme**: Tokyo Night theme for consistent dark aesthetics
- **Font**: FiraCode Nerd Font with ligatures and icon support
- **Performance**: GPU acceleration for smooth rendering
- **Productivity**: Quick terminal toggle and optimized keybinds

## Key Settings

- Font size: 14pt for optimal readability
- Block cursor without blinking for focus
- Balanced window padding (6px)
- Mouse hides while typing for clean experience
- Copy-on-select for convenient text copying
- No confirmation on close for reduced friction

## Installation

1. Install Ghostty terminal
2. Install FiraCode Nerd Font
3. Symlink config: `ln -sf ~/dotfiles/ghostty/.config/ghostty ~/.config/`
4. Grant Accessibility permissions for global quick terminal

## Quick Terminal

- **Toggle**: `Cmd + \`` (backtick)
- Requires Accessibility permissions in System Preferences

## Keybinds

- Tab management disabled (Cmd+T, Cmd+W, etc.)
- Uses native macOS shortcuts where possible
- Left Option key acts as Alt