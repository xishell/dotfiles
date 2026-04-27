#!/bin/bash

if [ -n "$CONFIG_DIR" ] && [ -f "$CONFIG_DIR/colors.sh" ]; then
    # Reuse the same palette values as the main bar config.
    . "$CONFIG_DIR/colors.sh"
fi

TARGET_WORKSPACE="$1"
FLASHSPACE_BIN="$2"

if [ -z "$FLASHSPACE_BIN" ] || [ ! -x "$FLASHSPACE_BIN" ]; then
    FLASHSPACE_BIN="/Applications/FlashSpace.app/Contents/Resources/flashspace"
fi

ACTIVE_WORKSPACE="${WORKSPACE:-$("$FLASHSPACE_BIN" get-workspace 2>/dev/null)}"

if [ "$TARGET_WORKSPACE" = "$ACTIVE_WORKSPACE" ]; then
    sketchybar --set "$NAME" icon.color="${SPACE_ACTIVE:-0xff8aadf4}" background.color="${BACKGROUND_1:-0x903c3e4f}"
else
    sketchybar --set "$NAME" icon.color="${SPACE_INACTIVE:-0xff939ab7}" background.color="${TRANSPARENT:-0x00000000}"
fi
