#!/bin/bash

spotify=(
  icon="$SPOTIFY_PLAYING"
  icon.font="$FONT:Medium:16.0"
  icon.color="$GREEN"
  icon.padding_left=10
  label="Not Playing"
  label.font="$FONT:Medium:12.0"
  label.color="$WHITE"
  label.max_chars=30
  padding_right=5
  padding_left=0
  update_freq=5
  updates=on
  script="$PLUGIN_DIR/spotify.sh"
  click_script="open -a Spotify"
  background.color="$BACKGROUND_1"
  background.corner_radius=8
  background.height=28
)

sketchybar --add item spotify right \
           --set spotify "${spotify[@]}"
