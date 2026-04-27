#!/bin/bash

network=(
  icon="$WIFI_CONNECTED"
  icon.font="$FONT:Medium:16.0"
  icon.padding_left=8
  icon.padding_right=4
  label.drawing=on
  label.font="$FONT:Medium:12.0"
  padding_right=2
  padding_left=0
  update_freq=10
  updates=on
  script="$PLUGIN_DIR/network.sh"
  click_script="open 'x-apple.systempreferences:com.apple.preference.network'"
)

sketchybar --add item network right \
           --set network "${network[@]}" \
           --subscribe network wifi_change system_woke
