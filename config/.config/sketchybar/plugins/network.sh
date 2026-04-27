#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"
CURRENT_WIFI="$(ipconfig getsummary en0)"
SSID="$(echo "$CURRENT_WIFI" | grep -o "SSID : .*" | sed 's/^SSID : //' | tail -n 1)"

if [ -z "$SSID" ]; then
    sketchybar --set "$NAME" \
        icon="$WIFI_DISCONNECTED" \
        icon.color="$RED" \
        label="Off"
else
    sketchybar --set "$NAME" \
        icon="$WIFI_CONNECTED" \
        icon.color="$WHITE"
    # label="$SSID"
fi
