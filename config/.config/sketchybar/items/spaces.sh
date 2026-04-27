#!/bin/bash

# Register FlashSpace event
sketchybar --add event flashspace_workspace_change

FLASHSPACE_BIN="/Applications/FlashSpace.app/Contents/Resources/flashspace"
if [ ! -x "$FLASHSPACE_BIN" ]; then
    FLASHSPACE_BIN="$(command -v flashspace 2>/dev/null)"
fi

WORKSPACES=("Browser" "Terminal" "Reader" "Discord" "Spotify" "Desktop")
ICONS=("$ICON_BROWSER" "$ICON_TERMINAL" "$ICON_READER" "$ICON_DISCORD" "$ICON_SPOTIFY" "$ICON_DESKTOP")

ACTIVE_WORKSPACE=$("$FLASHSPACE_BIN" get-workspace 2>/dev/null || echo "")

for i in "${!WORKSPACES[@]}"; do
    ws="${WORKSPACES[$i]}"
    icon="${ICONS[$i]}"
    sid=$((i + 1))

    if [ "$ws" = "$ACTIVE_WORKSPACE" ]; then
        COLOR=$SPACE_ACTIVE
        BG_COLOR=$BACKGROUND_1
    else
        COLOR=$SPACE_INACTIVE
        BG_COLOR=$TRANSPARENT
    fi

    sketchybar --add item space.$ws left \
        --set space.$ws \
        icon="$icon" \
        icon.color="$COLOR" \
        icon.font="$FONT:Medium:16.0" \
        icon.padding_left=8 \
        icon.padding_right=8 \
        label.drawing=off \
        background.color="$BG_COLOR" \
        background.corner_radius=8 \
        background.height=28 \
        script="$PLUGIN_DIR/flashspace.sh $ws $FLASHSPACE_BIN" \
        click_script="$FLASHSPACE_BIN workspace --name '$ws'" \
        --subscribe space.$ws flashspace_workspace_change
done
