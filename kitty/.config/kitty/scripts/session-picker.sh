#!/bin/sh
# floating session picker, args: main kitty socket, origin window id, switch|new|list|kill [name]
sock="$1"
origin="$2"
mode="${3:-switch}"
# layout templates, loaded when a new session's name matches one
dir="$HOME/.config/kitty/sessions"
# ad hoc sessions are scratch files scoped to this kitty pid, gone with it
run="${TMPDIR:-/tmp}/kitty-sessions-${sock##*-}"
# kitty actions launch with a bare PATH, fzf lives in homebrew
PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
# panels have no window chrome, so fzf draws the frame in tokyonight blue
style="--reverse --print-query --border=rounded --color=border:#7aa2f7,label:#7aa2f7,prompt:#7aa2f7"

is_live() {
    kitten @ --to "$sock" ls --match-tab "session:^$1\$" >/dev/null 2>&1
}

# ls has no session field, so probe each known name and drop dead scratch files
list() {
    for f in "$dir"/*.kitty-session "$run"/*.kitty-session; do
        [ -e "$f" ] || continue
        name=$(basename "$f" .kitty-session)
        if is_live "$name"; then
            echo "$name"
        else
            case "$f" in "$run"/*) rm -f "$f" ;; esac
        fi
    done | sort -u
}

case "$mode" in
list)
    list
    exit 0
    ;;
kill)
    [ -n "$4" ] && kitten @ --to "$sock" close-tab --match "session:^$4\$" >/dev/null 2>&1
    exit 0
    ;;
new)
    out=$(: | fzf $style --border-label ' new session ' --prompt '> ' --info hidden)
    ;;
*)
    out=$(list | fzf $style --border-label ' sessions ' --prompt '> ' \
        --header 'enter switch, ctrl-x kill, a new name creates it' \
        --bind "ctrl-x:execute-silent('$0' '$sock' '$origin' kill {})+reload('$0' '$sock' '$origin' list)")
    ;;
esac
# 130 is esc or ctrl+c, anything typed then is abandoned
[ $? -eq 130 ] && exit 0

query=$(printf '%s\n' "$out" | sed -n 1p)
pick=$(printf '%s\n' "$out" | sed -n 2p)
name=${pick:-$query}
[ -n "$name" ] || exit 0

file="$dir/$name.kitty-session"
# live name just switches, matches tmux new-session -A
if ! is_live "$name" && [ ! -e "$file" ]; then
    file="$run/$name.kitty-session"
    mkdir -p "$run"
    printf 'new_tab %s\nlayout splits\ncd %s\nlaunch\n' "$name" "$PWD" > "$file"
elif [ ! -e "$file" ]; then
    file="$run/$name.kitty-session"
fi

# focus first so goto_session lands in the main os window, not this panel
kitten @ --to "$sock" focus-window --match "id:$origin"
kitten @ --to "$sock" action --match "id:$origin" goto_session "$file"
