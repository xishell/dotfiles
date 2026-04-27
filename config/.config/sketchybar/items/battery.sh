#!/bin/bash

battery=(
  script="$PLUGIN_DIR/battery.sh"
  icon.font="$FONT:Regular:18.0"
  icon.padding_left=8
  icon.padding_right=4
  label.font="$FONT:Medium:12.0"
  padding_right=2
  padding_left=0
  label.drawing=on
  update_freq=120
  updates=on
)

sketchybar --add item battery right \
           --set battery "${battery[@]}" \
           --subscribe battery power_source_change system_woke
