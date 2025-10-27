# These mirror your eval lines, kept explicit for portability
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init --cmd cd zsh)"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# Auto-start tmux (preserved; simplified guard)
if command -v tmux >/dev/null 2>&1 && [[ -n $PS1 ]] && [[ $TERM != screen* ]] && [[ $TERM != tmux* ]] && [[ -z $TMUX ]]; then
    exec tmux
fi
