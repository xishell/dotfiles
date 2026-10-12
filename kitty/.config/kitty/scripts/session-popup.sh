#!/bin/sh
# opens session-picker.sh in a floating panel, args: origin window id, switch|new
exec kitten panel --edge=center-sized --lines=14 --columns=64 --layer=overlay \
    -o tab_bar_min_tabs=2 -o allow_remote_control=no -o listen_on=none -o startup_session=none \
    "$HOME/.config/kitty/scripts/session-picker.sh" "$KITTY_LISTEN_ON" "$1" "$2"
