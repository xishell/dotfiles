# XiShell Neovim Configuration

Modern Neovim configuration focused on development efficiency and seamless tmux integration.

## Key Features

- Modern plugin ecosystem with Lazy.nvim
- Fast completion with Blink.cmp
- Full LSP support via Mason
- Seamless tmux integration
- Git workflow with Gitsigns and LazyGit
- Smart navigation with Flash, Spider, and Harpoon
- Advanced text objects with Mini.ai
- Tokyo Night theme

## Installation

**Prerequisites:**
- Neovim 0.10+
- Git
- Nerd Font
- ripgrep
- Node.js

**Setup:**
```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.backup

# Link configuration
ln -sf ~/dotfiles/nvim/.config/nvim ~/.config/nvim
```

**First launch:** Plugins auto-install via Lazy.nvim

## Configuration Structure

```
lua/xishell/
├── init.lua          # Main entry point
├── options.lua       # Neovim settings
├── keymaps.lua       # Core keybindings
├── lazy_init.lua     # Plugin manager setup
├── auto.lua          # Autocommands
└── plugins/          # Plugin configurations
```

## Keybindings Reference

**Leader Keys:**
- Leader: `<Space>`
- Local Leader: `'`

### Core Movement & Editing

**Insert Mode:**
| Key | Action |
|-----|--------|
| `jk` | Exit to normal mode |
| `<A-j>` / `<A-k>` | Move line down/up |

**Navigation:**
| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Window navigation (tmux-aware) |
| `j` / `k` | Smart line movement (display vs actual) |
| `<S-h>` / `<S-l>` | Previous/next buffer |
| `w` / `e` / `b` | Spider motions (camelCase/snake_case aware) |

**Flash Navigation:**
| Key | Action |
|-----|--------|
| `s{char}{char}` | Jump to two-character match |
| `S` | Treesitter-aware jump |
| `r` | Remote operation (e.g., `dra` deletes to 'a') |
| `R` | Treesitter search (visual/operator mode) |

**Text Manipulation:**
| Key | Action |
|-----|--------|
| `<A-j>` / `<A-k>` | Move lines up/down |
| `x` / `X` | Delete without yank |
| `gco` / `gcO` | Add comment below/above |

**Surrounding (Mini.surround):**
| Key | Action |
|-----|--------|
| `sa` | Add surrounding (e.g., `saiw)` for word in parens) |
| `sd` | Delete surrounding (e.g., `sd)` removes parens) |
| `sr` | Replace surrounding (e.g., `sr)"` changes parens to quotes) |
| `sn` / `sl` | Find next/previous surrounding |

**Text Objects (Mini.ai):**
| Key | Action |
|-----|--------|
| `vif` / `vaf` | Inside/around function |
| `vic` / `vac` | Inside/around class |
| `vio` / `vao` | Inside/around code block (if/for/while) |
| `vit` / `vat` | Inside/around HTML/XML tags |
| `vid` / `vad` | Inside/around digits |
| `vie` / `vae` | Inside/around word with case (camelCase) |
| `vig` / `vag` | Inside/around entire buffer |
| `viu` / `vau` | Inside/around function call |

### Buffer & Tab Management

| Key | Action |
|-----|--------|
| `<leader>bb` | Toggle between current and previous buffer |
| `<leader>bd` | Delete buffer |
| `<leader>bD` | Delete buffer and window |
| `[b` / `]b` | Previous/next buffer |
| `<leader><tab><tab>` | New tab |
| `<leader><tab>d` | Close tab |
| `<leader><tab>[` / `]` | Previous/next tab |

### File Operations & Search

| Key | Action |
|-----|--------|
| `<leader><space>` | Find files |
| `<leader>ff` | Find files |
| `<leader>fg` | Git files |
| `<leader>fr` | Recent files |
| `<leader>fb` | Buffers |
| `<leader>/` | Live grep |
| `<leader>sg` | Grep with options |
| `<leader>sb` | Search buffer lines |
| `<leader>sw` | Grep word under cursor |
| `<leader>sd` | Search diagnostics |
| `<leader>sk` | Search keymaps |
| `<leader>sh` | Search help pages |

### Harpoon Navigation

| Key | Action |
|-----|--------|
| `<leader>a` | Add file to harpoon |
| `<C-e>` | Toggle harpoon menu |
| `<leader>1` | Jump to harpoon file 1 |
| `<leader>2` | Jump to harpoon file 2 |
| `<leader>3` | Jump to harpoon file 3 |
| `<leader>4` | Jump to harpoon file 4 |
| `<leader>fh` | Harpoon files + fuzzy finder |
| `<leader>fH` | Harpoon files only |

### Git Integration

**Snacks Git:**
| Key | Action |
|-----|--------|
| `<leader>gl` | LazyGit |
| `<leader>gs` | Git status |
| `<leader>gb` | Git blame line |
| `<leader>gf` | LazyGit file history |
| `<leader>gw` | Git browse web |

**Gitsigns:**
| Key | Action |
|-----|--------|
| `]h` / `[h` | Next/previous hunk |
| `]H` / `[H` | Last/first hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghS` | Stage buffer |
| `<leader>ghu` | Undo stage hunk |
| `<leader>ghR` | Reset buffer |
| `<leader>ghp` | Preview hunk inline |
| `<leader>ghd` | Diff this |
| `ih` | Select hunk (text object) |

### LSP & Development

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `gD` | Go to declaration |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `gs` | Signature help |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename |
| `<leader>cf` | Format buffer |
| `<leader>ss` | LSP symbols |
| `[d` / `]d` | Previous/next diagnostic |
| `gl` | Float diagnostic |

### Completion (Blink)

| Key | Action |
|-----|--------|
| `<C-Space>` | Show completion |
| `<Tab>` | Next item / snippet forward |
| `<S-Tab>` | Previous item / snippet backward |
| `<CR>` | Accept completion |
| `<C-e>` | Hide completion |

### Notes (Neorg)

| Key | Action |
|-----|--------|
| `<leader>nn` | Find notes |
| `<leader>nf` | Search notes |
| `<leader>nw` | Work notes |
| `<leader>np` | Personal notes |

### Utility

| Key | Action |
|-----|--------|
| `<leader>qq` | Quit all |
| `<leader>z` | Zen mode |
| `<leader>Z` | Zoom window |
| `<leader>n` | Notification history |
| `<leader>un` | Dismiss notifications |

## Plugin Overview

**Core:**
- Lazy.nvim - Plugin manager
- Blink.cmp - Completion engine
- Snacks.nvim - File operations, git, utilities

**LSP & Syntax:**
- nvim-lspconfig - LSP configurations
- Mason.nvim - LSP/tool installer
- mason-tool-installer.nvim - Auto-install formatters/linters
- nvim-treesitter - Syntax highlighting
- Conform.nvim - Formatting with LSP fallback

**Navigation:**
- Flash.nvim - Fast two-character jump
- nvim-spider - Smart word motions
- Harpoon - Quick file marks
- Oil.nvim - Directory editor
- vim-tmux-navigator - Tmux integration

**Text Objects & Editing:**
- Mini.ai - Advanced text objects
- Mini.surround - Surrounding operations
- nvim-autopairs - Auto-close brackets/quotes

**Git:**
- Gitsigns.nvim - Git signs and hunk operations
- Snacks.nvim - LazyGit integration

**UI:**
- Tokyo Night - Color scheme
- Lualine - Status line
- Bufferline - Buffer tabs
- Which-key - Keybinding help

**Other:**
- Neorg - Note-taking
- LuaSnip - Snippet engine
- Lazydev - Lua development
- VimTeX - LaTeX support

## Customization

**Add keybindings** in `lua/xishell/keymaps.lua`:
```lua
local map = vim.keymap.set
map("n", "<leader>custom", "<cmd>YourCommand<cr>", { desc = "Description" })
```

**Configure plugins** by editing files in `lua/xishell/plugins/`

**Change theme** in `lua/xishell/plugins/theme.lua`

## Integration Notes

- tmux: Seamless pane navigation with `<C-hjkl>`
- Shell: Optimized for zsh and modern terminals
- Git: LazyGit workflow + inline git signs
- Clipboard: Auto-detects SSH and adjusts clipboard behavior

This configuration prioritizes speed, efficiency, and vim conventions with modern enhancements.
