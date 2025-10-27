# Compinit already handled via atload in bundles.zsh.
# Put your styles here (kept from your .zshrc):
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

# fzf-tab previews you had:
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always --icons=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color=always --icons=always $realpath'

# Cache path for comps
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/completion"
