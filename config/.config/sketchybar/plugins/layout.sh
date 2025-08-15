#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

LAYOUT=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | grep -o '"KeyboardLayout Name" = "[^"]*"' | awk -F'"' '{print $4}')
if [ "$LAYOUT" = "" ]; then
  exit 0
fi

DRAWING=on
COLOR=$WHITE
case ${LAYOUT} in
  "USInternational-PC") ICON=US;
  ;;
  "Swedish - Pro") ICON=􁂷;
  ;;
  *) ICON=$BATTERY_0; COLOR=$RED
esac

sketchybar --set "$NAME" \
    drawing="$DRAWING" \
    icon="$ICON" \
    icon.color="$COLOR"

