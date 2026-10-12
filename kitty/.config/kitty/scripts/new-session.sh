#!/bin/sh
# prompts for a name, writes a session rooted at the caller's cwd, switches to it
dir="$HOME/.config/kitty/sessions"
printf 'Session name: '
read -r name
[ -n "$name" ] || exit 0
file="$dir/$name.kitty-session"
# existing name just switches, matches tmux new-session -A
if [ ! -e "$file" ]; then
    mkdir -p "$dir"
    printf 'new_tab %s\nlayout splits\ncd %s\nlaunch\n' "$name" "$PWD" > "$file"
fi
kitten @ action goto_session "$file"
