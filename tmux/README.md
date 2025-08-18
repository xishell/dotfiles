# Tmux Configuration

Terminal multiplexer configuration with vim-style navigation and modern workflow enhancements.

## Features

- **Vim integration**: Seamless navigation between tmux panes and vim splits
- **Modern keybinds**: Intuitive pane splitting and window management
- **Tokyo Night theme**: Consistent dark aesthetics with customizations
- **Plugin system**: TPM (Tmux Plugin Manager) with essential plugins

## Key Bindings

### Prefix Key
- **Prefix**: `Ctrl-a` (instead of default Ctrl-b)

### Pane Navigation
- **Vim keys**: `h/j/k/l` (with prefix)
- **Alt + arrows**: Navigate without prefix
- **Alt + h/l**: Switch windows without prefix

### Window Management
- **Shift + arrows**: Switch windows
- **Alt + H/L**: Switch windows (vim-style)

### Pane Management
- **Split vertical**: `prefix + |`
- **Split horizontal**: `prefix + -`
- **New window**: `prefix + c` (opens in current directory)
- **Kill pane**: `prefix + x`
- **Kill window**: `prefix + &`

### Copy Mode (Vi-style)
- **Enter copy mode**: `prefix + [`
- **Begin selection**: `v`
- **Rectangle selection**: `Ctrl-v`
- **Copy selection**: `y`

## Plugins

- **TPM**: Plugin manager
- **tmux-sensible**: Sensible default settings
- **vim-tmux-navigator**: Seamless vim/tmux navigation
- **tokyo-night-tmux**: Dark theme with customizations
- **tmux-yank**: Enhanced copy/paste functionality

## Theme Customization

- Path display: Enabled (relative format)
- Window ID style: Double square brackets
- Git integration: Disabled
- DateTime: Disabled for clean status bar

## Installation

1. Install TPM:
   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```

2. Symlink config:
   ```bash
   ln -sf ~/dotfiles/tmux/.config/tmux ~/.config/
   ```

3. Reload tmux and install plugins:
   ```bash
   tmux source-file ~/.config/tmux/tmux.conf
   # Press prefix + I to install plugins
   ```

## Performance Optimizations

- **Escape time**: 0ms for instant vim responsiveness
- **Focus events**: Enabled for better vim integration
- **True color**: Full 24-bit color support
- **Mouse support**: Enabled for modern workflow

## Workflow Tips

- Use `Ctrl-a + L` to clear screen (preserves tmux history)
- Windows and panes start at index 1 for easier access
- Automatic window renumbering keeps indices sequential
- All splits open in current working directory

## Plugins Used

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
