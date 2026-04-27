# Auto-show repo todos on cd / shell start
function show_git_todos() {
    if git rev-parse --show-toplevel >/dev/null 2>&1; then
        local root
        root=$(git rev-parse --show-toplevel 2>/dev/null)
        local reponame
        reponame=$(basename "$root")
        if [[ -f "$root/todos.json" ]]; then
            echo "📋 Todos for repo: $reponame"
            godo --list "$root/todos.json"
            echo
        fi
    fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd show_git_todos
show_git_todos

# yazi: cd to dir on exit
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
