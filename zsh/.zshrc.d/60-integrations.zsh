# Shell integrations
eval "$(fzf --zsh)"

# navi cheatsheets, ctrl-g pulls up the interactive picker
if command -v navi &>/dev/null; then
    eval "$(navi widget zsh)"
fi
# Claude Code expects standard `cd` semantics; zoxide's fuzzy-jump on
# missing paths leaves the agent in unexpected dirs.
if [ -z "$CLAUDECODE" ]; then
    eval "$(zoxide init --cmd cd zsh)"
else
    eval "$(zoxide init zsh)"
fi

# auto-start tmux, skipped in IDE terminals, nested sessions, kitty and shells
# without a real terminal (e.g. the one uwsm runs at login to load the environment)
if command -v tmux &>/dev/null && [ -n "$PS1" ] && [ -t 0 ] && [ -t 1 ] &&
    [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] &&
    [ -z "$TMUX" ] && [ -z "$VSCODE_RESOLVING_ENVIRONMENT" ] &&
    [ -z "$TERMINAL_EMULATOR" ] && [ -z "$KITTY_WINDOW_ID" ]; then
    tmux new-session -A -s main
fi

# Lazy-load nvm — only initializes on first use of a node-family command
export NVM_DIR="$HOME/.nvm"
lazy_load_nvm() {
    unset -f nvm node npm npx pnpm pnpx corepack
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
for cmd in nvm node npm npx pnpm pnpx corepack; do
    eval "${cmd}() { lazy_load_nvm; ${cmd} \"\$@\"; }"
done
