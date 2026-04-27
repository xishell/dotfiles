setopt EXTENDED_GLOB

# vi-mode keybindings
bindkey -v
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Open command in $EDITOR with v from normal mode
autoload -z edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
