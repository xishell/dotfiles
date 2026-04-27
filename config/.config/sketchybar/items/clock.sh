#!/bin/bash

clock=(
  icon="$CLOCK_ICON"
  icon.font="$FONT:Medium:15.0"
  icon.padding_left=8
  icon.padding_right=4
  label.font="$FONT:Medium:12.0"
  padding_right=2
  padding_left=0
  update_freq=30
  updates=on
  script="$PLUGIN_DIR/clock.sh"
)

sketchybar --add item clock right \
           --set clock "${clock[@]}" \
           --subscribe clock system_woke
