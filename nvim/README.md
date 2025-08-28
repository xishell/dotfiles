# XiShell Neovim Configuration

A modern, feature-rich Neovim configuration focused on development efficiency and seamless tmux integration.

## ✨ Key Features

- **Modern Plugin Ecosystem**: Lazy.nvim package manager with carefully selected plugins
- **Advanced Completion**: Blink.cmp for fast, intelligent code completion
- **Seamless tmux Integration**: Unified navigation between Neovim and tmux panes
- **LSP Support**: Full Language Server Protocol support with Mason for easy management
- **Git Integration**: Comprehensive git workflow with Snacks and LazyGit
- **Smart File Management**: Oil.nvim for intuitive directory editing
- **Beautiful UI**: Tokyo Night theme with customized lualine and bufferline

## 📦 Installation

1. **Prerequisites**:
   - Neovim 0.10+ 
   - Git
   - A Nerd Font (for icons)
   - ripgrep (for searching)
   - Node.js (for some LSP servers)

2. **Install Configuration**:
   ```bash
   # Backup existing config if needed
   mv ~/.config/nvim ~/.config/nvim.backup
   
   # Clone and link this configuration
   ln -sf ~/dotfiles/nvim/.config/nvim ~/.config/nvim
   ```

3. **First Launch**: Open Neovim - plugins will auto-install via Lazy.nvim

## ⚙️ Configuration Structure

```
lua/xishell/
├── init.lua          # Main entry point
├── options.lua       # Neovim settings
├── keymaps.lua       # Core keybindings
├── lazy_init.lua     # Plugin manager setup
├── auto.lua          # Autocommands
└── plugins/          # Plugin configurations
    ├── blink.lua     # Completion engine
    ├── lspconfig.lua # Language servers
    ├── snacks.lua    # File operations & git
    ├── oil.lua       # Directory editor
    └── ...
```

## 🚀 Keybindings Reference

### Leader Keys
- **Leader**: `<Space>`
- **Local Leader**: `'`

### Core Movement & Editing

#### Insert Mode
| Key | Action | Description |
|-----|--------|-------------|
| `jj` / `jk` | `<Esc>` | Exit to normal mode |
| `<A-j>` / `<A-k>` | Move line down/up | Move current line |

#### Navigation
| Key | Action | Description |
|-----|--------|-------------|
| `<C-h/j/k/l>` | Window navigation | Move between splits (tmux-aware) |
| `j` / `k` | Smart line movement | Display lines vs actual lines |
| `<S-h>` / `<S-l>` | Buffer navigation | Previous/next buffer |

#### Text Manipulation
| Key | Action | Description |
|-----|--------|-------------|
| `<A-j>` / `<A-k>` | Move lines | Move selected lines up/down |
| `x` / `X` | Delete without yank | No clipboard pollution |
| `gco` / `gcO` | Add comment | Comment below/above current line |

### Buffer & Tab Management
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>bb` | Switch buffer | Toggle between current and previous |
| `<leader>bd` | Delete buffer | Smart buffer deletion |
| `<leader>bD` | Delete buffer & window | Force deletion |
| `[b` / `]b` | Buffer navigation | Previous/next buffer |
| `<leader><tab><tab>` | New tab | Create new tab |
| `<leader><tab>d` | Close tab | Delete current tab |
| `<leader><tab>[` / `<leader><tab>]` | Tab navigation | Previous/next tab |

### File Operations & Search (Snacks)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader><space>` | Find files | Fuzzy file finder |
| `<leader>ff` | Find files | Same as above |
| `<leader>fg` | Git files | Find in git repository |
| `<leader>fr` | Recent files | Recently opened files |
| `<leader>fb` | Buffers | Switch between open buffers |
| `<leader>/` | Live grep | Search in project |
| `<leader>sg` | Grep | Search with options |
| `<leader>sb` | Buffer lines | Search current buffer |
| `<leader>fh` | Harpoon + Files | Harpooned files + fuzzy finder |
| `<leader>fH` | Harpoon Files | Show only harpooned files |

### Notes & Knowledge Management (Neorg)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>nn` | Find Notes | Browse all notes |
| `<leader>nf` | Search Notes | Search within notes |
| `<leader>nw` | Work Notes | Browse work-specific notes |
| `<leader>np` | Personal Notes | Browse personal notes |

### Git Integration (Snacks)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>gl` | LazyGit | Full git interface |
| `<leader>gs` | Git status | Quick status overview |
| `<leader>gb` | Git blame | Blame current line |
| `<leader>gf` | File history | LazyGit file history |
| `<leader>gw` | Git browse | Open in web browser |

### LSP & Development
| Key | Action | Description |
|-----|--------|-------------|
| `gd` | Go to definition | Jump to symbol definition |
| `gr` | Find references | Show all references |
| `gI` | Go to implementation | Jump to implementation |
| `gy` | Go to type definition | Jump to type definition |
| `<leader>ss` | LSP symbols | Search project symbols |
| `<leader>sd` | Diagnostics | Show diagnostics |

### Completion (Blink)
| Key | Action | Description |
|-----|--------|-------------|
| `<C-Space>` | Trigger completion | Manual completion trigger |
| `<Tab>` | Accept/Next | Accept suggestion or next item |
| `<S-Tab>` | Previous | Previous completion item |
| `<C-e>` | Close | Close completion menu |

### Utility & System
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>qq` | Quit all | Exit Neovim |
| `<leader>z` | Zen mode | Distraction-free editing |
| `<leader>Z` | Zoom | Zoom current window |
| `<leader>n` | Notifications | Show notification history |
| `<leader>sk` | Keymaps | Search available keymaps |
| `<leader>sh` | Help pages | Search help documentation |

### File Navigation (Harpoon)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>a` | Add to harpoon | Mark current file for quick access |
| `<C-e>` | Harpoon menu | Toggle harpoon quick menu |
| `<C-h>` | Harpoon file 1 | Jump to first harpooned file |
| `<C-t>` | Harpoon file 2 | Jump to second harpooned file |
| `<C-n>` | Harpoon file 3 | Jump to third harpooned file |
| `<C-s>` | Harpoon file 4 | Jump to fourth harpooned file |

### Search Enhancement
| Key | Action | Description |
|-----|--------|-------------|
| `n` / `N` | Smart search | Context-aware next/previous |
| `<leader>fs` | Spell suggestions | Spelling corrections |

## 🔌 Plugin Overview

### Core Plugins
- **[Lazy.nvim](https://github.com/folke/lazy.nvim)**: Plugin manager
- **[Blink.cmp](https://github.com/saghen/blink.cmp)**: Fast completion engine
- **[Snacks.nvim](https://github.com/folke/snacks.nvim)**: File operations, git, and utilities

### LSP & Development
- **[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)**: LSP configurations
- **[Mason.nvim](https://github.com/williamboman/mason.nvim)**: LSP/tool installer
- **[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)**: Syntax highlighting

### UI & Theme
- **[Tokyo Night](https://github.com/folke/tokyonight.nvim)**: Color scheme
- **[Lualine](https://github.com/nvim-lualine/lualine.nvim)**: Status line
- **[Bufferline](https://github.com/akinsho/bufferline.nvim)**: Buffer tabs

### Navigation & Integration
- **[Oil.nvim](https://github.com/stevearc/oil.nvim)**: Directory editor
- **[Harpoon](https://github.com/ThePrimeagen/harpoon)**: Quick file navigation
- **[Neorg](https://github.com/nvim-neorg/neorg)**: Note-taking and organization
- **[vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)**: Seamless tmux integration
- **[Which-key](https://github.com/folke/which-key.nvim)**: Keybinding help

## 🎛️ Customization

### Adding New Keybindings
Add custom keymaps to `lua/xishell/keymaps.lua`:
```lua
local map = vim.keymap.set
map("n", "<leader>custom", "<cmd>YourCommand<cr>", { desc = "Your Description" })
```

### Plugin Configuration
Each plugin has its own file in `lua/xishell/plugins/`. Modify these files to customize plugin behavior.

### Theme Customization
Modify `lua/xishell/plugins/theme.lua` to change colors or switch themes.

## 🤝 Integration Notes

- **tmux**: Configured for seamless pane navigation with `<C-hjkl>`
- **Shell**: Works best with zsh and modern terminal emulators
- **Git**: Optimized workflow with LazyGit and built-in git operations
- **File Management**: Oil.nvim provides vim-native directory editing

---

*This configuration prioritizes speed, efficiency, and a clean development experience. All keybindings follow vim conventions while adding modern conveniences.*