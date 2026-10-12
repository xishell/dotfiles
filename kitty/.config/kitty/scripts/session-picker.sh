#!/bin/sh
# floating session picker, args: main kitty socket, origin window id, switch|new
sock="$1"
origin="$2"
mode="${3:-switch}"
dir="$HOME/.config/kitty/sessions"
# kitty actions launch with a bare PATH, fzf lives in homebrew
PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
# panels have no window chrome, so fzf draws the frame in tokyonight blue
style="--reverse --print-query --border=rounded --color=border:#7aa2f7,label:#7aa2f7,prompt:#7aa2f7"

if [ "$mode" = new ]; then
    out=$(: | fzf $style --border-label ' new session ' --prompt '> ' --info hidden)
else
    out=$(cd "$dir" && ls ./*.kitty-session 2>/dev/null | sed 's|^\./||; s|\.kitty-session$||' |
        fzf $style --border-label ' sessions ' --prompt '> ' \
            --header 'enter switch, a new name creates it')
fi
# 130 is esc or ctrl+c, anything typed then is abandoned
[ $? -eq 130 ] && exit 0

query=$(printf '%s\n' "$out" | sed -n 1p)
pick=$(printf '%s\n' "$out" | sed -n 2p)
name=${pick:-$query}
[ -n "$name" ] || exit 0

file="$dir/$name.kitty-session"
# existing name just switches, matches tmux new-session -A
if [ ! -e "$file" ]; then
    mkdir -p "$dir"
    printf 'new_tab %s\nlayout splits\ncd %s\nlaunch\n' "$name" "$PWD" > "$file"
fi

# focus first so goto_session lands in the main os window, not this panel
kitten @ --to "$sock" focus-window --match "id:$origin"
kitten @ --to "$sock" action --match "id:$origin" goto_session "$file"
