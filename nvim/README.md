# XiShell Neovim Configuration

Modern Neovim configuration focused on development efficiency and seamless tmux integration.

## Key Features

- Fast startup with `vim.loader.enable()`
- Modern plugin ecosystem with Lazy.nvim
- Completion with Blink.cmp (including SQL autocomplete)
- Full LSP support via Mason with auto-installed formatters/linters
- Linting via nvim-lint (eslint_d, ruff, shellcheck, golangci-lint, etc.)
- Debugging with nvim-dap (C/C++, Python, Go)
- Integrated test runner with Neotest (Python, Go, Jest, Vitest, Java)
- Session management with persistence.nvim
- Database client with vim-dadbod (PostgreSQL, MySQL, SQLite, etc.)
- Typst support with live preview, tinymist LSP, and ~80 snippets for math/academic writing
- Seamless tmux integration
- Git workflow with Gitsigns and LazyGit
- Smart navigation with Flash, Spider, and Harpoon
- Advanced text objects with Mini.ai
- Central config with local override support
- Tokyo Night theme

## Installation

**Prerequisites:**
- Neovim 0.10+
- Git
- Nerd Font
- ripgrep (`rg`)
- Node.js (for some LSPs)

**Optional:**
- `fd` - Fast file finder
- `lazygit` - Git TUI

**Setup:**
```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.backup

# Link configuration
ln -sf ~/dotfiles/nvim/.config/nvim ~/.config/nvim
```

**First launch:** Plugins auto-install via Lazy.nvim

**Verify setup:**
```vim
:checkhealth xishell
```

## Configuration Structure

```
lua/xishell/
├── init.lua          # Main entry, leader keys, local config loading
├── config.lua        # Central configuration with defaults
├── health.lua        # Custom :checkhealth module
├── options.lua       # Neovim settings
├── keymaps.lua       # Core keybindings
├── lazy_init.lua     # Plugin manager setup
├── auto.lua          # Autocommands
├── c_projects.lua    # C/C++ include path detection
├── config/           # Plugin-specific configs
│   ├── mason.lua     # LSP servers, formatters, linters, debug adapters
│   ├── treesitter.lua
│   └── snacks/
└── plugins/          # Plugin configurations
```

## Local Configuration

Override defaults by creating `~/.nvim.lua` or `.nvim.lua` in your project:

```lua
return {
  -- Notes directory paths
  notes = {
    dir = "~/my-notes",
    work = "~/my-notes/work",
    personal = "~/my-notes/personal",
  },

  -- Database connections for vim-dadbod
  databases = {
    dev = "postgresql://user@localhost:5432/mydb",
    staging = "postgresql://user@staging:5432/mydb",
  },

  -- Disable formatting for specific filetypes
  format_disabled_ft = { "markdown" },
}
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
| `<C-h/j/k/l>` | Window/tmux pane navigation |
| `j` / `k` | Smart line movement (display vs actual) |
| `<S-h>` / `<S-l>` | Previous/next buffer |
| `[b` / `]b` | Previous/next buffer |
| `w` / `e` / `b` | Spider motions (camelCase/snake_case aware) |

**Flash Navigation:**
| Key | Action |
|-----|--------|
| `s` | Flash jump (two-character search) |
| `S` | Flash treesitter (normal/operator mode) |
| `r` | Remote operation (operator mode) |
| `R` | Treesitter search (operator/visual mode) |
| `<C-s>` | Toggle Flash in command-line mode |

**Text Manipulation:**
| Key | Action |
|-----|--------|
| `<A-j>` / `<A-k>` | Move lines up/down (normal/insert/visual) |
| `x` | Delete char without yank |
| `X` | Delete backward without yank |
| `gco` / `gcO` | Add comment below/above |
| `gcc` | Comment toggle current line |
| `gc` | Comment toggle linewise (normal/visual) |
| `gb` | Comment toggle blockwise (normal/visual) |

**Surrounding (Mini.surround):**
| Key | Action |
|-----|--------|
| `ys` | Add surrounding (e.g., `ysiw)` for word in parens) |
| `ds` | Delete surrounding (e.g., `ds)` removes parens) |
| `cs` | Change surrounding (e.g., `cs)"` changes parens to quotes) |
| `S` | Add surrounding (visual mode) |

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
| `<leader><tab>l` | Last tab |
| `<leader><tab>o` | Close other tabs |
| `<leader><tab>f` | First tab |

### File Operations & Search (Snacks Picker)

| Key | Action |
|-----|--------|
| `<leader><space>` | Find files |
| `<leader>ff` | Find files |
| `<leader>fg` | Git files |
| `<leader>fr` | Recent files |
| `<leader>fb` | Buffers |
| `<leader>fs` | Spelling suggestions |
| `<leader>/` | Live grep |
| `<leader>:` | Command history |
| `<leader>sg` | Grep with options |
| `<leader>sb` | Search buffer lines |
| `<leader>sB` | Grep open buffers |
| `<leader>sw` | Grep word under cursor |
| `<leader>sd` | Diagnostics |
| `<leader>sk` | Search keymaps |
| `<leader>sh` | Search help pages |
| `<leader>sH` | Search highlights |
| `<leader>ss` | LSP symbols |
| `<leader>sj` | Jumps |
| `<leader>sl` | Location list |
| `<leader>sm` | Marks |
| `<leader>sM` | Man pages |
| `<leader>sq` | Quickfix list |
| `<leader>sR` | Resume |
| `<leader>s"` | Registers |
| `<leader>sa` | Autocmds |
| `<leader>sc` | Command history |
| `<leader>sC` | Commands |

### File Explorer (Oil)

| Key | Action |
|-----|--------|
| `-` | Open parent directory |

### Harpoon Navigation

| Key | Action |
|-----|--------|
| `<leader>a` | Add file to harpoon |
| `<C-g>` | Toggle harpoon menu |
| `<leader>1` - `<leader>4` | Jump to harpoon file 1-4 |
| `<leader>fh` | Harpoon files + fuzzy finder |
| `<leader>fH` | Harpoon files only |

### Git Integration

**Snacks Git:**
| Key | Action |
|-----|--------|
| `<leader>gl` | LazyGit |
| `<leader>gL` | LazyGit log (cwd) |
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
| `<leader>ghD` | Diff this ~ |
| `ih` | Select hunk (text object, visual/operator) |

### LSP & Development

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `go` | Go to type definition |
| `gI` | Incoming calls |
| `gO` | Outgoing calls |
| `K` | Hover documentation |
| `gs` | Signature help |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename |
| `<leader>cR` | Rename file |
| `<leader>cd` | Document diagnostics (loclist) |
| `<leader>cD` | Workspace diagnostics (qflist) |
| `<leader>cf` | Format buffer |
| `[d` / `]d` | Previous/next diagnostic |
| `gl` | Float diagnostic |
| `]]` / `[[` | Next/previous reference |

### Completion (Blink)

| Key | Action |
|-----|--------|
| `<C-Space>` | Show completion |
| `<Tab>` | Next item / snippet forward / tab out |
| `<S-Tab>` | Previous item / snippet backward |
| `<CR>` | Accept completion |
| `<C-e>` | Hide completion |
| `<C-Up>` / `<C-Down>` | Scroll documentation |

### Debugging (nvim-dap)

| Key | Action |
|-----|--------|
| `<leader>Dc` | Continue |
| `<leader>Db` | Toggle breakpoint |
| `<leader>DB` | Conditional breakpoint |
| `<leader>Do` | Step over |
| `<leader>Di` | Step into |
| `<leader>DO` | Step out |
| `<leader>Dr` | Toggle REPL |
| `<leader>Dl` | Run last |
| `<leader>Dt` | Terminate |
| `<leader>Du` | Toggle DAP UI |
| `<leader>De` | Eval expression (normal/visual) |

**Supported adapters:**
- C/C++: codelldb
- Python: debugpy (auto-detects virtualenv)
- Go: delve (via go.nvim)

### Database (vim-dadbod)

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle Database UI |
| `<leader>df` | Find Database Buffer |
| `<leader>dr` | Rename Database Buffer |
| `<leader>dq` | Last Query Info |

**Usage:**
1. Configure databases in `~/.nvim.lua` (see Local Configuration)
2. Open DBUI with `<leader>db`
3. Navigate tree and press `<CR>` to connect
4. Write SQL queries - autocomplete available in `.sql` files

### Testing (Neotest)

| Key | Action |
|-----|--------|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run test file |
| `<leader>ta` | Run all tests |
| `<leader>tl` | Run last test |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Show test output |
| `<leader>tO` | Toggle output panel |
| `<leader>tS` | Stop test |
| `<leader>td` | Debug nearest test |
| `<leader>tw` | Toggle watch mode |
| `]t` / `[t` | Next/previous failed test |

**Supported frameworks:**
- Python: pytest
- Go: go test
- JavaScript/TypeScript: Jest, Vitest
- Java: JUnit

### Notes (Neorg)

| Key | Action |
|-----|--------|
| `<leader>nn` | Find notes |
| `<leader>nf` | Search notes |
| `<leader>nw` | Work notes |
| `<leader>np` | Personal notes |

### Session Management (persistence.nvim)

| Key | Action |
|-----|--------|
| `<leader>qs` | Restore session |
| `<leader>qS` | Select session |
| `<leader>ql` | Restore last session |
| `<leader>qd` | Don't save current session |
| `<leader>qp` | Projects |

### C/C++ Projects

| Key | Action |
|-----|--------|
| `<leader>mb` | Build C/C++ file |
| `<leader>mr` | Build and run C/C++ file |

Auto-detects `include/` directories and Meson build systems.

### Typst (localleader `'`)

**Preview:**
| Key | Action |
|-----|--------|
| `'tp` | Start live preview |
| `'ts` | Stop preview |
| `'tt` | Toggle preview |
| `'tf` | Toggle follow cursor |
| `'tc` | Sync cursor to preview |

**Editor settings:** 2-space indent, soft wrap, spellcheck enabled.

**Snippets (via LuaSnip):**

| Trigger | Description |
|---------|-------------|
| **Templates** | |
| `report` | Full report template (title, author, headings, equation numbering) |
| `notes` | Course notes template with ctheorems (theorem/def/proof environments) |
| `hw` | Homework/assignment template |
| **Math** | |
| `mk` / `dm` | Inline / display math |
| `//` | Fraction `frac(a, b)` |
| `td` / `__` | Superscript / subscript |
| `sum`, `prod`, `lim` | Big operators with bounds |
| `int` / `dint` | Integral / definite integral |
| `sq` / `nrt` | Square root / nth root |
| `mat2` / `mat3` | 2x2 / 3x3 matrix |
| `vec2` / `vec3` | 2D / 3D column vector |
| `lr(` / `lr[` / `lr\|` | Auto-sized delimiters |
| `norm` | Norm |
| `hat`, `bar`, `tld`, `vc` | Accents (hat, overline, tilde, bold) |
| `pd` / `dd` / `grad` | Partial derivative / derivative / gradient |
| `NN`, `ZZ`, `QQ`, `RR`, `CC` | Number sets |
| `aa` / `ee` | For all / exists |
| `set` | Set builder notation |
| **Symbols** | |
| `ooo` | Infinity |
| `...` | Centered dots |
| `=>`, `=<`, `<>` | Implies, implied by, iff |
| `!=`, `<=`, `>=` | Not equal, leq, geq |
| `inn` / `notin` | Element of / not element of |
| **Environments (ctheorems)** | |
| `thm`, `lem`, `cor` | Theorem, lemma, corollary |
| `def`, `exm`, `rmk` | Definition, example, remark |
| `prf` | Proof |
| `cthm` | Import + set up all theorem environments |
| **Structure** | |
| `h1`, `h2`, `h3` | Headings |
| `fig` / `tbl` | Figure / table with caption and optional label |
| `code` | Code block with language |
| `box` / `alert` | Colored box / callout box |
| `cols` | Multi-column layout |
| `quote` | Block quote with attribution |
| `lst` / `enum` | Bullet / numbered list |
| **Formatting** | |
| `bf` / `it` | Bold / italic (supports visual selection) |
| `ul` / `hl` / `sc` | Underline / highlight / smallcaps |
| `ref` / `lab` / `cite` | Reference / label / citation |
| `imp` | Import package |
| `pb` | Page break |

**Recommended packages:**
- `ctheorems` - Theorem environments (included in `notes` template)
- `fletcher` - Commutative diagrams and flowcharts
- `physica` - Physics notation shortcuts
- `algorithmic` - Pseudocode blocks

### Java (ftplugin)

| Key | Action |
|-----|--------|
| `<leader>oi` | Organize imports |
| `<leader>ev` | Extract variable |
| `<leader>em` | Extract method (visual) |

### UI & Utility

| Key | Action |
|-----|--------|
| `<leader>w` | Save file |
| `<leader>wa` | Save all files |
| `<leader>wq` | Save and quit |
| `<leader>qq` | Quit all |
| `<leader>z` | Zen mode |
| `<leader>Z` | Zoom window |
| `<leader>n` | Notification history |
| `<leader>un` | Dismiss notifications |
| `<leader>us` | Toggle spelling |
| `<leader>ud` | Toggle diagnostics |
| `<leader>uT` | Toggle treesitter |
| `<leader>uX` | Colorscheme picker |

## Plugin Overview

**Core:**
- Lazy.nvim - Plugin manager
- Blink.cmp - Completion engine with LuaSnip + friendly-snippets
- Snacks.nvim - Picker, git, notifications, zen mode, utilities

**LSP & Syntax:**
- nvim-lspconfig - LSP configurations
- Mason.nvim - LSP/tool installer
- mason-tool-installer.nvim - Auto-install formatters/linters
- nvim-treesitter - Syntax highlighting + textobjects + context
- Conform.nvim - Formatting with LSP fallback
- nvim-lint - Linting (eslint_d, ruff, shellcheck, golangci-lint, etc.)

**Development Tools:**
- nvim-dap + dap-ui - Debugging (C/C++, Python, Go)
- Neotest - Test runner (Python, Go, Jest, Vitest, Java)
- vim-dadbod suite - Database client with UI and autocomplete
- Lazydev - Lua/Neovim development

**Navigation:**
- Flash.nvim - Fast character jump (`s` / `S`)
- nvim-spider - Smart word motions (camelCase aware)
- Harpoon v2 - Quick file marks (`<C-g>` menu)
- Oil.nvim - Directory editor
- vim-tmux-navigator - Seamless tmux pane navigation

**Text Objects & Editing:**
- Mini.ai - Advanced text objects (function, class, block, etc.)
- Mini.surround - Surrounding operations (`ys`/`ds`/`cs`)
- nvim-autopairs - Auto-close brackets/quotes
- Tabout.nvim - Tab out of brackets/quotes
- Comment.nvim - Line/block commenting

**Git:**
- Gitsigns.nvim - Git signs and hunk operations
- Snacks.nvim - LazyGit integration, blame, browse

**UI:**
- Tokyo Night - Color scheme
- Lualine - Status line
- Bufferline - Buffer tabs
- Which-key - Keybinding help with group labels
- Mini.icons - File icons

**Session & Workflow:**
- persistence.nvim - Auto-save/restore sessions

**Language-specific:**
- go.nvim - Go development
- nvim-jdtls - Java development
- VimTeX - LaTeX support
- typst-preview.nvim - Typst live preview with tinymist LSP
- Custom Typst snippets - Math, templates, theorem environments (~80 snippets)
- Neorg - Note-taking system

## Customization

**Add keybindings** in `lua/xishell/keymaps.lua`:
```lua
local map = vim.keymap.set
map("n", "<leader>custom", "<cmd>YourCommand<cr>", { desc = "Description" })
```

**Configure plugins** by editing files in `lua/xishell/plugins/`

**Override defaults** via `~/.nvim.lua` or project-local `.nvim.lua`

**Change theme** in `lua/xishell/plugins/theme.lua`

**Add/remove Mason tools** in `lua/xishell/config/mason.lua`

## Health Check

Run `:checkhealth xishell` to verify:
- vim.loader status
- Notes directory existence
- External tools (git, rg, fd, lazygit, node)
- Formatters and LSP servers
- Plugin count and startup time
- Clipboard, termguicolors, undodir

## Integration Notes

- **tmux:** Seamless pane navigation with `<C-hjkl>`
- **Shell:** Optimized for zsh and modern terminals
- **Git:** LazyGit workflow + inline git signs (loads only if git available)
- **Clipboard:** Auto-detects SSH and adjusts clipboard behavior
- **Database:** SQL autocomplete in SQL files when connected
- **Testing:** Inline test results with multiple framework support
- **Large files:** Formatting auto-disabled for files >1MB
