# NvimX Configuration

Minimal, fast Neovim configuration optimized for macOS development with essential plugins and clean aesthetics.

## Philosophy

NvimX is designed as a lightweight alternative to the full XiShell configuration, focusing on:
- **Minimalism**: Only essential plugins and features
- **Speed**: Fast startup and responsive editing
- **macOS Integration**: Native macOS workflows and shortcuts
- **Clean UI**: Distraction-free editing environment

## Features

- **Fast Plugin Management**: Lazy.nvim with minimal plugin set
- **LSP Support**: Essential language servers with clean completion
- **Project Navigation**: Telescope for fuzzy finding
- **Git Integration**: Basic git workflow support
- **macOS Optimized**: Tailored for macOS development patterns

## Key Plugins

### Core
- **lazy.nvim**: Fast plugin manager
- **telescope.nvim**: Fuzzy finder for files and text
- **treesitter**: Syntax highlighting and text objects

### LSP & Development
- **nvim-lspconfig**: Language server configurations
- **cmp-nvim-lsp**: LSP completion source
- **snacks.nvim**: Lightweight utilities collection

### UI
- **Minimal theme**: Clean, distraction-free interface
- **Project management**: Simple project switching
- **Optimized status**: Lightweight status information

### macOS Integration
- **Native shortcuts**: Familiar macOS keybindings where appropriate
- **Clipboard integration**: Seamless copy/paste workflows
- **Performance tuned**: Optimized for macOS file systems

## Key Bindings

### Leader Key
- **Leader**: `Space`
- **Local Leader**: `Space`

### Essential Navigation
- **Find files**: `<leader>ff`
- **Find text**: `<leader>fg` 
- **Recent files**: `<leader>fr`
- **Buffers**: `<leader>fb`

### LSP Basics
- **Go to definition**: `gd`
- **Find references**: `gr`
- **Hover info**: `K`
- **Code actions**: `<leader>ca`

### Project Management
- **Project files**: `<leader>fp`
- **Project switch**: `<leader>pp`

## Installation

1. **Backup existing config**:
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Symlink NvimX**:
   ```bash
   ln -sf ~/dotfiles/nvimx/.config/nvimx ~/.config/nvim
   ```

3. **Install dependencies**:
   ```bash
   # Essential tools
   brew install ripgrep fd
   brew install node # for LSP servers
   ```

4. **First run**:
   - Open Neovim: `nvim`
   - Plugins auto-install via Lazy.nvim
   - LSP servers install as needed

## Configuration Structure

```
nvimx/.config/nvimx/
├── init.lua              # Bootstrap and main setup
├── lua/config/
│   ├── options.lua       # Editor settings
│   ├── keymaps.lua       # Key mappings
│   └── autocmds.lua      # Auto commands
└── lua/plugins/
    ├── core.lua          # Essential plugins
    ├── ui.lua            # Interface plugins
    ├── telescope.lua     # Fuzzy finding
    ├── treesitter.lua    # Syntax highlighting
    ├── snacks.lua        # Utilities
    ├── project.lua       # Project management
    ├── macos.lua         # macOS specific features
    ├── formatting.lua    # Code formatting
    └── lsp/
        ├── init.lua      # LSP setup
        └── servers.lua   # Server configurations
```

## Language Support

### Built-in
- **Lua**: Full support with lua-language-server
- **Python**: pyright integration
- **JavaScript/TypeScript**: typescript-language-server
- **JSON/YAML**: Basic editing support

### Adding Languages
Add servers to `lua/plugins/lsp/servers.lua`:
```lua
return {
  "your-language-server",
  -- configuration...
}
```

## Differences from XiShell

| Feature | NvimX | XiShell |
|---------|-------|---------|
| Plugin count | ~15 | ~30+ |
| Startup time | <50ms | ~100ms |
| Complexity | Minimal | Full-featured |
| Customization | Basic | Extensive |
| Target | Quick editing | Full development |

## When to Use NvimX

- **Quick edits**: Fast file editing and code reviews
- **Minimal setup**: When you want essential features only
- **Performance**: On slower machines or remote systems
- **Learning**: Understanding core Neovim before adding complexity
- **Focused work**: Distraction-free coding sessions

## Switching Between Configs

```bash
# Switch to NvimX
ln -sf ~/dotfiles/nvimx/.config/nvimx ~/.config/nvim

# Switch to full XiShell
ln -sf ~/dotfiles/nvim/.config/nvim ~/.config/nvim
```

## Customization

- **Minimal by design**: Add features intentionally
- **Plugin additions**: Use `lua/plugins/` for new functionality
- **Theme changes**: Modify `lua/plugins/ui.lua`
- **Keybinding updates**: Edit `lua/config/keymaps.lua`