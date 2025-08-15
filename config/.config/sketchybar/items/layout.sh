#!/bin/bash

layout=(
  script="$PLUGIN_DIR/layout.sh"
  icon.font="$FONT:Regular:18.0"
  padding_right=5
  padding_left=0
  label.drawing=on
  update_freq=20
  updates=on
)

sketchybar --add item layout right      \
           --set layout "${layout[@]}" \
           --subscribe layout

