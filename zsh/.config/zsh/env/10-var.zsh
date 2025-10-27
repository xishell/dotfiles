export EDITOR=nvim
export PAGER=less
export LESS='-R'

# History (mirrors your current settings, with a bigger wheel if you want)
HISTFILE=${HISTFILE:-$HOME/.zsh_history}
HISTSIZE=5000
SAVEHIST=$HISTSIZE
setopt appendhistory sharehistory # keep as you had
setopt hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups
