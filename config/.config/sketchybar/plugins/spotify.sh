#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

RUNNING=$(pgrep -x "Spotify" 2>/dev/null)

if [ -z "$RUNNING" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

STATE=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)

if [ "$STATE" = "playing" ]; then
  TRACK=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null)
  ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null)
  sketchybar --set "$NAME" \
    drawing=on \
    icon.color="$GREEN" \
    label="$ARTIST - $TRACK"
elif [ "$STATE" = "paused" ]; then
  TRACK=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null)
  ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null)
  sketchybar --set "$NAME" \
    drawing=on \
    icon.color="$GREY" \
    label="$ARTIST - $TRACK"
else
  sketchybar --set "$NAME" drawing=off
fi
