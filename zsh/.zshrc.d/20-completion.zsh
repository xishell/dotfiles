# fpath additions must come BEFORE compinit
if type brew &>/dev/null; then
    fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi
# htb-toolkit completions (post-split — framework lives in ~/projects/htb-toolkit)
fpath=($HOME/projects/htb-toolkit/completions $fpath)

# Load completions
autoload -Uz compinit && compinit

# Register htb-toolkit completion mappings after compinit
autoload -Uz _htb         2>/dev/null && compdef _htb         htb
autoload -Uz _htba        2>/dev/null && compdef _htba        htba
autoload -Uz _htbl        2>/dev/null && compdef _htbl        htbl
autoload -Uz _htb-setup   2>/dev/null && compdef _htb-setup   htb-setup
autoload -Uz _htb-update  2>/dev/null && compdef _htb-update  htb-update

# Replay zinit-queued completions after compinit
zinit cdreplay -q

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always --icons=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color=always --icons=always $realpath'
