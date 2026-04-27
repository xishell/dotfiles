# fpath additions must come BEFORE compinit
if type brew &>/dev/null; then
    fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi
fpath=($HOME/htb/completions $fpath)

# Load completions
autoload -Uz compinit && compinit

# Register htb completion mapping after compinit
autoload -Uz _htb 2>/dev/null && compdef _htb htb

# Replay zinit-queued completions after compinit
zinit cdreplay -q

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always --icons=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color=always --icons=always $realpath'
