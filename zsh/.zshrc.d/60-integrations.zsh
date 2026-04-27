# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Auto-start tmux (skip inside IDE terminals and nested sessions)
if command -v tmux &>/dev/null && [ -n "$PS1" ] &&
    [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] &&
    [ -z "$TMUX" ] && [ -z "$VSCODE_RESOLVING_ENVIRONMENT" ] &&
    [ -z "$TERMINAL_EMULATOR" ]; then
    tmux new-session -A -s main
fi

# Lazy-load nvm — only initializes on first use of node/npm/npx/nvm
export NVM_DIR="$HOME/.nvm"
lazy_load_nvm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
for cmd in nvm node npm npx; do
    eval "${cmd}() { lazy_load_nvm; ${cmd} \"\$@\"; }"
done
