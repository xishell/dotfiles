# Neovim Keymaps Cheat Sheet

## Global
### Insert mode

| Key | Action | Source File |
|-----|--------|-------------|
| `<A-j>` | Move Down | `lua/xishell/keymaps.lua` |
| `<A-k>` | Move Up | `lua/xishell/keymaps.lua` |

### Normal mode

| Key | Action | Source File |
|-----|--------|-------------|
| `<A-j>` | Move Down | `lua/xishell/keymaps.lua` |
| `<A-k>` |  | `lua/xishell/keymaps.lua` |
| `<C-h>` | Go to Left Window | `lua/xishell/keymaps.lua` |
| `<C-j>` | Go to Lower Window | `lua/xishell/keymaps.lua` |
| `<C-k>` | Go to Upper Window | `lua/xishell/keymaps.lua` |
| `<C-l>` | Go to Right Window | `lua/xishell/keymaps.lua` |
| `<S-h>` | Prev Buffer | `lua/xishell/keymaps.lua` |
| `<S-l>` | Next Buffer | `lua/xishell/keymaps.lua` |
| `<leader><tab><tab>` | New Tab | `lua/xishell/keymaps.lua` |
| `<leader><tab>[` | Previous Tab | `lua/xishell/keymaps.lua` |
| `<leader><tab>]` | Next Tab | `lua/xishell/keymaps.lua` |
| `<leader><tab>d` | Close Tab | `lua/xishell/keymaps.lua` |
| `<leader><tab>f` | First Tab | `lua/xishell/keymaps.lua` |
| `<leader><tab>l` | Last Tab | `lua/xishell/keymaps.lua` |
| `<leader><tab>o` | Close Other Tabs | `lua/xishell/keymaps.lua` |
| `<leader>`` | Switch to Other Buffer | `lua/xishell/keymaps.lua` |
| `<leader>bD` | Delete Buffer and Window | `lua/xishell/keymaps.lua` |
| `<leader>bb` | Switch to Other Buffer | `lua/xishell/keymaps.lua` |
| `<leader>qq` | Quit All | `lua/xishell/keymaps.lua` |
| `N` | Prev Search Result | `lua/xishell/keymaps.lua` |
| `X` |  | `lua/xishell/options.lua` |
| `[b` | Prev Buffer | `lua/xishell/keymaps.lua` |
| `]b` | Next Buffer | `lua/xishell/keymaps.lua` |
| `gcO` | Add Comment Above | `lua/xishell/keymaps.lua` |
| `gco` | Add Comment Below | `lua/xishell/keymaps.lua` |
| `n` | Next Search Result | `lua/xishell/keymaps.lua` |
| `q` |  | `lua/xishell/auto.lua` |
| `x` |  | `lua/xishell/options.lua` |

### n,x mode

| Key | Action | Source File |
|-----|--------|-------------|
| `<Down>` | Down | `lua/xishell/keymaps.lua` |
| `<Up>` | Up | `lua/xishell/keymaps.lua` |
| `j` | Down | `lua/xishell/keymaps.lua` |
| `k` | Up | `lua/xishell/keymaps.lua` |

### Operator mode

| Key | Action | Source File |
|-----|--------|-------------|
| `N` | Prev Search Result | `lua/xishell/keymaps.lua` |
| `n` | Next Search Result | `lua/xishell/keymaps.lua` |

### Visual mode

| Key | Action | Source File |
|-----|--------|-------------|
| `<A-j>` | Move Down | `lua/xishell/keymaps.lua` |
| `<A-k>` |  | `lua/xishell/keymaps.lua` |

### Visual mode

| Key | Action | Source File |
|-----|--------|-------------|
| `N` | Prev Search Result | `lua/xishell/keymaps.lua` |
| `n` | Next Search Result | `lua/xishell/keymaps.lua` |



## Snacks keymaps

| Key | Action | Source File |
|-----|--------|-------------|
| `<leader>z` | Toggle Zen Mode | `plugins/snacks.lua` |
| `<leader>Z` | Toggle Zoom | `plugins/snacks.lua` |
| `<leader>n` | Notification History | `plugins/snacks.lua` |
| `<leader>bd` | Delete Buffer | `plugins/snacks.lua` |
| `<leader>cR` | Rename File | `plugins/snacks.lua` |
| `<leader>gw` | Git Browse Web | `plugins/snacks.lua` |
| `<leader>gb` | Git Blame Line | `plugins/snacks.lua` |
| `<leader>gf` | Lazygit Current File History | `plugins/snacks.lua` |
| `<leader>gl` | Lazygit | `plugins/snacks.lua` |
| `<leader>gL` | Lazygit Log (cwd) | `plugins/snacks.lua` |
| `<leader>un` | Dismiss All Notifications | `plugins/snacks.lua` |
| `<leader>/` | Grep | `plugins/snacks.lua` |
| `<leader>:` | Command History | `plugins/snacks.lua` |
| `<leader><space>` | Find Files | `plugins/snacks.lua` |
| `<leader>fb` | Buffers | `plugins/snacks.lua` |
| `<leader>ff` | Find Files | `plugins/snacks.lua` |
| `<leader>fg` | Find Git Files | `plugins/snacks.lua` |
| `<leader>fr` | Recent | `plugins/snacks.lua` |
| `<leader>gl` | Git Log | `plugins/snacks.lua` |
| `<leader>gs` | Git Status | `plugins/snacks.lua` |
| `<leader>sb` | Buffer Lines | `plugins/snacks.lua` |
| `<leader>sB` | Grep Open Buffers | `plugins/snacks.lua` |
| `<leader>sg` | Grep | `plugins/snacks.lua` |
| `<leader>sa` | Autocmds | `plugins/snacks.lua` |
| `<leader>sc` | Command History | `plugins/snacks.lua` |
| `<leader>sC` | Commands | `plugins/snacks.lua` |
| `<leader>sd` | Diagnostics | `plugins/snacks.lua` |
| `<leader>sh` | Help Pages | `plugins/snacks.lua` |
| `<leader>sH` | Highlights | `plugins/snacks.lua` |
| `<leader>sj` | Jumps | `plugins/snacks.lua` |
| `<leader>sk` | Keymaps | `plugins/snacks.lua` |
| `<leader>sl` | Location List | `plugins/snacks.lua` |
| `<leader>sM` | Man Pages | `plugins/snacks.lua` |
| `<leader>sm` | Marks | `plugins/snacks.lua` |
| `<leader>sR` | Resume | `plugins/snacks.lua` |
| `<leader>sq` | Quickfix List | `plugins/snacks.lua` |
| `<leader>uX` | Colorschemes | `plugins/snacks.lua` |
| `<leader>qp` | Projects | `plugins/snacks.lua` |
| `<leader>fs` | Spelling suggestions | `plugins/snacks.lua` |
| `gd` | Goto Definition | `plugins/snacks.lua` |
| `gr` | References | `plugins/snacks.lua` |
| `gI` | Goto Implementation | `plugins/snacks.lua` |
| `gy` | Goto T[y]pe Definition | `plugins/snacks.lua` |
| `<leader>ss` | LSP Symbols | `plugins/snacks.lua` |
## Blink (insert-mode completion)

| Key | Action | Source File |
|-----|--------|-------------|
| `<C-space>` | ` | `lua/xishell/plugins/blink.lua` |
