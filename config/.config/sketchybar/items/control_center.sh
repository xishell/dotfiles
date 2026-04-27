#!/bin/bash

control_center=(
  icon="$CONTROL_CENTER"
  icon.font="$FONT:Medium:16.0"
  icon.color="$WHITE"
  icon.padding_left=8
  icon.padding_right=8
  label.drawing=off
  padding_right=0
  padding_left=0
  click_script="open 'x-apple.systempreferences:com.apple.ControlCenter'"
)

sketchybar --add item control_center right \
           --set control_center "${control_center[@]}"
